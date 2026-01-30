# 📁 Configuración SSH para GitHub

Este directorio contiene las claves SSH y la configuración para acceder a diferentes servicios.

## 🔑 Claves SSH Generadas

| Clave | Propósito | Email |
|-------|-----------|-------|
| `id_ed25519_server` | Servidores (KVM, VPS, etc.) | [COMPLETAR] |
| `id_ed25519_github` | Cuenta principal de GitHub | [COMPLETAR] |
| `id_ed25519_other` | Otros usos | [COMPLETAR] |

---

## 🐙 Configuración de Múltiples Cuentas de GitHub

### Opción 1: Usar SSH Config con diferentes hosts

Edita el archivo `~/.ssh/config` y agrega diferentes hosts para cada cuenta:

```ssh
# Cuenta principal (j0k3r)
Host github-j0k3r
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

# Cuenta secundaria (otra-cuenta)
Host github-otra
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_other
    IdentitiesOnly yes
```

### Opción 2: Cambiar URL del repositorio remoto

Para cambiar un repositorio existente a usar una cuenta específica:

```bash
# Ver URL actual
git remote -v

# Cambiar a cuenta principal (j0k3r)
git remote set-url origin git@github-j0k3r:J0k3r-rg/repositorio.git

# Cambiar a cuenta secundaria
git remote set-url origin git@github-otra:otra-cuenta/repositorio.git
```

### Opción 3: Clonar directamente con la cuenta correcta

```bash
# Clonar con cuenta principal
git clone git@github-j0k3r:J0k3r-rg/mi-repositorio.git

# Clonar con cuenta secundaria
git clone git@github-otra:otra-cuenta/repositorio.git
```

---

## 📋 Plantilla para Nuevos Repositorios

### Para cuenta principal (j0k3r):

```bash
# 1. Clonar o crear repositorio
git clone git@github-j0k3r:J0k3r-rg/nombre-repositorio.git
cd nombre-repositorio

# 2. Configurar usuario local (si es diferente al global)
git config user.name "J0k3r"
git config user.email "tu-email@principal.com"

# 3. Verificar configuración
git config --list --local | grep user
```

### Para cuenta secundaria:

```bash
# 1. Clonar con el host correcto
git clone git@github-otra:otra-cuenta/repositorio.git
cd repositorio

# 2. Configurar usuario para este repositorio
git config user.name "Nombre Usuario"
git config user.email "email@secundario.com"

# 3. Verificar
git config --list --local | grep user
```

---

## 🔧 Comandos Útiles

### Ver qué clave se está usando
```bash
# Simular conexión SSH
ssh -T git@github.com
ssh -T git@github-j0k3r
```

### Ver configuración global de Git
```bash
git config --global --list
```

### Ver configuración del repositorio actual
```bash
git config --local --list
git config user.name
git config user.email
```

### Cambiar usuario en repositorio existente
```bash
git config user.name "Nombre de la Cuenta"
git config user.email "email@cuenta.com"
```

---

## 🚨 Solución de Problemas

### "Permission denied" al hacer push

Verifica que la clave pública esté agregada en GitHub:
1. Ve a: https://github.com/settings/keys
2. Agrega el contenido de `id_ed25519_github.pub` (o la clave correspondiente)

### Verificar qué clave se está intentando usar
```bash
GIT_SSH_COMMAND="ssh -v" git push
```

### Forzar el uso de una clave específica
```bash
GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_github" git push
```

---

## 📝 Notas

- Las claves privadas deben tener permisos `600`
- Las claves públicas pueden tener permisos `644`
- Nunca compartas tus claves privadas
- Cada cuenta de GitHub debe tener su propia clave SSH

---

## 🔗 Links Útiles

- [GitHub SSH Keys](https://github.com/settings/keys)
- [Git SSH Documentation](https://git-scm.com/book/en/v2/Git-on-the-Server-The-Protocols)
- [SSH Config](https://www.ssh.com/academy/ssh/config)

---

*Generado automáticamente por install_ssh.sh*
