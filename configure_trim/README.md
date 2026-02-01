# Configuración de TRIM

Este módulo configura el servicio `fstrim.timer` para asegurar que la función TRIM se ejecute regularmente en tu sistema, mejorando el rendimiento y la vida útil de los discos de estado sólido (SSD).

## ¿Qué es TRIM y por qué es importante?

TRIM es un comando de la interfaz ATA que permite al sistema operativo informar a una unidad de estado sólido (SSD) qué bloques de datos ya no están en uso y pueden ser borrados internamente. Cuando eliminas un archivo en un sistema operativo, los bloques de datos no se borran inmediatamente, solo se marcan como "disponibles" para futuras escrituras. Sin TRIM, la SSD no sabría qué bloques están realmente libres, lo que puede llevar a una degradación del rendimiento con el tiempo.

**Beneficios de TRIM:**

*   **Rendimiento sostenido:** Ayuda a mantener la velocidad de escritura de la SSD, evitando que se ralentice progresivamente.
*   **Mayor vida útil:** Al permitir que la SSD gestione sus bloques de memoria de manera más eficiente, se reduce el desgaste innecesario y se extiende la vida útil de la unidad.

## Configuración Implementada

Por defecto, en muchas distribuciones Linux, `fstrim.timer` está configurado para ejecutarse semanalmente. Sin embargo, en esta configuración, hemos realizado los siguientes ajustes mediante un archivo `override.conf` en `/etc/systemd/system/fstrim.timer.d/`:

```
[Timer]
OnCalendar=
OnCalendar=daily
Persistent=true
```

### Explicación de los Parámetros:

*   **`OnCalendar=`**: La primera línea vacía `OnCalendar=` tiene el propósito de limpiar cualquier configuración previa de `OnCalendar` que pudiera existir en el archivo original de la unidad de timer.
*   **`OnCalendar=daily`**: Esta configuración ajusta el temporizador para que se ejecute una vez al día a las 00:00 (medianoche). Si el sistema está apagado en ese momento, el comando se ejecutará tan pronto como el sistema se inicie.
*   **`Persistent=true`**: Este es un parámetro crucial. Por defecto, si el sistema está apagado en el momento programado para la ejecución del temporizador, la tarea se omite y se espera hasta el próximo ciclo programado. Al establecer `Persistent=true`, se garantiza que si el temporizador no se pudo ejecutar en el horario previsto (por ejemplo, porque el equipo estaba apagado), se ejecutará tan pronto como sea posible una vez que el sistema se inicie nuevamente. Esto asegura que la limpieza de TRIM se realice de manera consistente sin importar el tiempo de actividad del sistema.

Con esta configuración, tu SSD mantendrá un rendimiento óptimo y una mayor durabilidad, ya que los bloques de datos no utilizados serán gestionados eficientemente de forma diaria y persistente.
