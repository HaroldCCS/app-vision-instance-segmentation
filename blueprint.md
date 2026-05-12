# Visión general

Esta es una sencilla aplicación de Flutter que calcula la edad de una persona en años, semanas y días a partir de su fecha de nacimiento.

## Plan actual

- **Interfaz de usuario (UI):**
    - Un `AppBar` con el título "Calculadora de Edad".
    - Un botón para abrir un selector de fecha.
    - Secciones de texto para mostrar la fecha de nacimiento seleccionada y los resultados calculados (años, semanas, días).
- **Lógica:**
    - Usar `showDatePicker` para permitir al usuario seleccionar su fecha de nacimiento.
    - Calcular la diferencia entre la fecha actual y la fecha de nacimiento seleccionada.
    - Convertir la diferencia en total de años, semanas y días.
    - Actualizar la interfaz de usuario para mostrar los resultados.
- **Manejo de estado:**
    - Utilizar `ValueNotifier` para gestionar el estado de la fecha de nacimiento seleccionada y los resultados calculados, asegurando que la interfaz de usuario se actualice de manera eficiente.
