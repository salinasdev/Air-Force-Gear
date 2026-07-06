# Android Squadron 2 - Port 1:1 a Godot

Esta versión empieza la reorganización del remake hacia un port fiel 1:1.

## Cambios estructurales

- `scripts/managers/LevelConfig.gd`: tabla única de los 9 niveles originales.
- `scripts/ui/ResultFrames.gd`: definición de frames para `AFG-LevelCompleted.png` y `AFG-LevelGameOver.png`.
- `scripts/Main.gd`: sigue siendo la escena de arranque, pero ya delega configuración de niveles y animaciones de resultado.

## Próximo refactor recomendado

- Extraer jugador a `scripts/entities/Player.gd`.
- Extraer enemigos a `scripts/entities/Enemy.gd`.
- Extraer items de fuel/lapsed fuel a `scripts/entities/Item.gd`.
- Extraer HUD a `scripts/ui/HUD.gd`.
- Mantener una tabla de equivalencias Java -> Godot para revisar comportamiento 1:1.
