#!/bin/bash

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   echo "Please run with sudo: sudo ./configure_trim.sh"
   exit 1
fi

echo "Configuring fstrim.timer for daily execution and persistence..."

# Create the override directory if it doesn't exist
mkdir -p /etc/systemd/system/fstrim.timer.d/

# Create the override.conf file
sudo cat << EOF > /etc/systemd/system/fstrim.timer.d/override.conf
[Timer]
OnCalendar=
OnCalendar=daily
Persistent=true
EOF

if [ $? -eq 0 ]; then
    echo "fstrim.timer override.conf created successfully."
else
    echo "Error: Failed to create fstrim.timer override.conf."
    exit 1
fi

# Reload systemd to pick up the new configuration
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start the fstrim.timer
echo "Enabling and starting fstrim.timer..."
systemctl enable fstrim.timer
if [ $? -eq 0 ]; then
    echo "fstrim.timer enabled successfully."
else
    echo "Error: Failed to enable fstrim.timer."
    exit 1
fi

systemctl start fstrim.timer
if [ $? -eq 0 ]; then
    echo "fstrim.timer started successfully."
else
    echo "Error: Failed to start fstrim.timer."
    exit 1
fi

echo "fstrim.timer is now configured to run daily and persistently."

# Ask user if they want to run fstrim.service immediately
read -p "¿Desea ejecutar fstrim.service ahora para limpiar el disco? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]
then
    echo "Ejecutando sudo systemctl start fstrim.service..."
    systemctl start fstrim.service
    if [ $? -eq 0 ]; then
        echo "fstrim.service ejecutado exitosamente."
    else
        echo "Error: Falló la ejecución de fstrim.service. Verifique los logs con 'journalctl -u fstrim.service'."
        exit 1
    fi
else
    echo "fstrim.service no se ejecutará ahora. Se ejecutará según el temporizador configurado."
fi

echo "Configuración de TRIM completada."
