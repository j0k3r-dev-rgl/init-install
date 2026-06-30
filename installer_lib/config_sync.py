from __future__ import annotations

import filecmp
import hashlib
import shutil
from dataclasses import dataclass
from pathlib import Path


IGNORED_NAMES = {".git", "node_modules", "__pycache__", ".cache"}


@dataclass(frozen=True)
class ConfigTarget:
    key: str
    title: str
    repo_relative: str
    home_relative: str

    def repo_path(self, repo_root: Path) -> Path:
        return repo_root / self.repo_relative

    def home_path(self, home_root: Path) -> Path:
        return home_root / self.home_relative


@dataclass(frozen=True)
class SyncPlan:
    key: str
    source: Path
    destination: Path
    status: str
    added_count: int = 0
    changed_count: int = 0
    removed_count: int = 0

    @property
    def needs_confirmation(self) -> bool:
        return self.status == "different"

    @property
    def summary(self) -> str:
        if self.status == "missing_source":
            return "fuente no encontrada"
        if self.status == "missing_destination":
            return "destino no existe; se puede copiar sin backup"
        if self.status == "identical":
            return "igual; se omite"
        if self.status == "different":
            return (
                f"diferente; +{self.added_count} nuevos, "
                f"~{self.changed_count} modificados, -{self.removed_count} solo destino"
            )
        return self.status


@dataclass(frozen=True)
class SyncResult:
    key: str
    action: str
    source: Path
    destination: Path
    backup_path: Path | None = None
    message: str = ""


def _file_hash(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _snapshot(path: Path) -> dict[str, str]:
    if path.is_file():
        return {path.name: _file_hash(path)}
    files: dict[str, str] = {}
    for child in sorted(path.rglob("*")):
        if any(part in IGNORED_NAMES for part in child.relative_to(path).parts):
            continue
        if child.is_file():
            files[child.relative_to(path).as_posix()] = _file_hash(child)
    return files


def _same_path(source: Path, destination: Path) -> bool:
    if source.is_file() and destination.is_file():
        return filecmp.cmp(source, destination, shallow=False)
    if source.is_dir() and destination.is_dir():
        return _snapshot(source) == _snapshot(destination)
    return False


def compare_paths(key: str, source: Path, destination: Path) -> SyncPlan:
    source = Path(source)
    destination = Path(destination)

    if not source.exists():
        return SyncPlan(key=key, source=source, destination=destination, status="missing_source")
    if not destination.exists():
        added = len(_snapshot(source)) if source.is_dir() else 1
        return SyncPlan(
            key=key,
            source=source,
            destination=destination,
            status="missing_destination",
            added_count=added,
        )
    if _same_path(source, destination):
        return SyncPlan(key=key, source=source, destination=destination, status="identical")

    source_snapshot = _snapshot(source)
    destination_snapshot = _snapshot(destination)
    source_keys = set(source_snapshot)
    destination_keys = set(destination_snapshot)
    added = len(source_keys - destination_keys)
    removed = len(destination_keys - source_keys)
    changed = sum(
        1
        for relative in source_keys & destination_keys
        if source_snapshot[relative] != destination_snapshot[relative]
    )
    return SyncPlan(
        key=key,
        source=source,
        destination=destination,
        status="different",
        added_count=added,
        changed_count=changed,
        removed_count=removed,
    )


def _copy_path(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        shutil.copytree(source, destination, ignore=shutil.ignore_patterns(*IGNORED_NAMES))
    else:
        shutil.copy2(source, destination)


def _remove_path(path: Path) -> None:
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()


def _merge_path(source: Path, destination: Path) -> None:
    if source.is_file():
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
        return

    destination.mkdir(parents=True, exist_ok=True)
    for child in sorted(source.rglob("*")):
        relative = child.relative_to(source)
        if any(part in IGNORED_NAMES for part in relative.parts):
            continue
        target = destination / relative
        if child.is_dir():
            target.mkdir(parents=True, exist_ok=True)
        elif child.is_file():
            target.parent.mkdir(parents=True, exist_ok=True)
            if not target.exists() or _file_hash(child) != _file_hash(target):
                shutil.copy2(child, target)


def _backup_destination(plan: SyncPlan, backup_root: Path, timestamp: str) -> Path:
    backup_path = backup_root / timestamp / plan.key
    if backup_path.exists():
        suffix = 2
        while (backup_root / timestamp / f"{plan.key}-{suffix}").exists():
            suffix += 1
        backup_path = backup_root / timestamp / f"{plan.key}-{suffix}"
    backup_path.parent.mkdir(parents=True, exist_ok=True)
    if plan.destination.is_dir() and not plan.destination.is_symlink():
        shutil.copytree(plan.destination, backup_path)
    else:
        backup_path.mkdir(parents=True, exist_ok=True)
        shutil.copy2(plan.destination, backup_path / plan.destination.name)
    return backup_path


def apply_sync_plan(
    plan: SyncPlan,
    *,
    backup_root: Path,
    confirmed: bool,
    timestamp: str,
) -> SyncResult:
    backup_root = Path(backup_root)

    if plan.status == "missing_source":
        return SyncResult(plan.key, "skipped", plan.source, plan.destination, message="fuente no encontrada")
    if plan.status == "identical":
        return SyncResult(plan.key, "skipped", plan.source, plan.destination, message="sin cambios")
    if plan.status == "different" and not confirmed:
        return SyncResult(plan.key, "cancelled", plan.source, plan.destination, message="cancelado por usuario")

    backup_path: Path | None = None
    if plan.destination.exists():
        backup_path = _backup_destination(plan, backup_root, timestamp)
        if plan.source.is_dir() and plan.destination.is_dir():
            _merge_path(plan.source, plan.destination)
        else:
            _remove_path(plan.destination)
            _copy_path(plan.source, plan.destination)
        return SyncResult(plan.key, "updated", plan.source, plan.destination, backup_path=backup_path)

    _copy_path(plan.source, plan.destination)
    return SyncResult(plan.key, "copied", plan.source, plan.destination, backup_path=None)


DEFAULT_CONFIG_TARGETS: tuple[ConfigTarget, ...] = (
    ConfigTarget("hyprland", "Hyprland", "hyprland/configs", ".config/hypr"),
    ConfigTarget("mango", "Mango", "mango/configs", ".config/mango"),
    ConfigTarget("noctalia", "Noctalia Shell", "noctalia/configs", ".config/noctalia"),
    ConfigTarget("waybar", "Waybar", "waybar/configs", ".config/waybar"),
    ConfigTarget("kitty", "Kitty", "kitty/configs", ".config/kitty"),
    ConfigTarget("rofi", "Rofi", "rofi/configs", ".config/rofi"),
    ConfigTarget("swaync", "swaync", "swaync/configs", ".config/swaync"),
    ConfigTarget("wlogout", "wlogout", "wlogout/configs", ".config/wlogout"),
    ConfigTarget("nvim", "Neovim", "nvim/configs", ".config/nvim"),
    ConfigTarget("yazi", "Yazi", "yazi/configs", ".config/yazi"),
    ConfigTarget("opencode", "Opencode", "opencode/configs", ".config/opencode"),
)
