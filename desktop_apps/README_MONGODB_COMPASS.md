# MongoDB Compass

## Instalación

MongoDB Compass se instala automáticamente al ejecutar `install_desktop_apps.sh` (pregunta interactiva).

### Instalación Manual

```bash
cd ~/instalacion-inicial/desktop_apps
./install_mongodb_compass.sh
```

## Ubicación

- **Binario**: `/opt/mongodb-compass/MongoDB Compass`
- **Lanzador**: `~/.local/share/applications/mongodb-compass.desktop`
- **Versión**: `/opt/mongodb-compass/.version`

## Uso

### Ejecutar desde Rofi
Busca "MongoDB Compass" en Rofi (SUPER + D)

### Ejecutar desde terminal
```bash
/opt/mongodb-compass/MongoDB\ Compass
```

### Actualizar
```bash
mongodb-compass-update
```

Este comando:
- Detecta la versión instalada
- Consulta la última versión disponible en GitHub
- Descarga e instala automáticamente si hay actualización
- Pregunta confirmación antes de actualizar

## Actualización Manual

```bash
cd ~/instalacion-inicial/desktop_apps
./update_mongodb_compass.sh
```

## Desinstalación

```bash
sudo rm -rf /opt/mongodb-compass
rm ~/.local/share/applications/mongodb-compass.desktop
rm ~/.local/bin/mongodb-compass-update
```
