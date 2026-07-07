# ✈ Air Force Gear — Definitive Edition


> **Shooter vertical de aviones** — remasterización completa en Godot 4 del juego original para Android.

---

## 🎮 Descripción

**Air Force Gear: Definitive Edition** es un shooter vertical de acción frenética en el que pilotas un avión de combate a través de 9 niveles de dificultad creciente, un modo Torneo y una misión especial contra el temible **Acorazado**.

Originalmente creado para Android, esta edición definitiva reimplementa el juego desde cero en **Godot 4**, manteniendo la esencia del original y añadiendo nuevas mecánicas, mayor variedad de combate y una secuencia de muerte del jefe completamente nueva.

---

## 🕹️ Modos de juego

| Modo | Descripción |
|---|---|
| **Campaña** | 9 niveles en 3 escenarios (Taiga, Mar, Tundra) × 3 momentos del día |
| **Extra Flight** | Enfrenta a 70 enemigos y al Acorazado en una sola misión |
| **Tournament** | Recorre todos los escenarios en un megamapa continuo, 240 enemigos |

---

## ⚔️ Mecánicas

- **3 armas**: Normal, Mave y Harry — cada una con mayor potencia y cadencia
- **Sistema de combustible**: gestiona tu fuel o el vuelo termina
- **Pickups**: combustible, vida y mejoras de arma caen de los enemigos abatidos
- **4 patrones de movimiento enemigo**: recto, zigzag, en picado y flanqueo lateral
- **3 tipos de disparo enemigo**: recto, apuntado al jugador y abanico de 3 balas
- **Sistema de ranking**: puntuaciones guardadas por nivel y modo Torneo

---

## 👾 El Acorazado (Boss)

El jefe final del modo Extra Flight cuenta con **4 ataques especiales**:

| Ataque | Efecto |
|---|---|
| **Radio Location** | Escanea la pantalla y lanza un misil teledirigido |
| **Icy Prison** | 3 proyectiles de hielo que congelan al jugador 2.6 segundos |
| **Igneus Breath** | Carga y dispara una columna de fuego devastadora |
| **Error 43** | Fallo del sistema — suelta objetos beneficiosos para el jugador |

Al derrotarlo, una **secuencia espectacular de ~4 segundos** llena la pantalla de explosiones escalonadas mientras la nave se hunde y desaparece.

---

## 🗺️ Escenarios y dificultad

Cada entorno se juega en tres momentos del día que afectan la velocidad, HP y agresividad de los enemigos:

| Momento | Enemigos | Velocidad | Consumo de fuel |
|---|---|---|---|
| **Mañana** | Pocos, lentos | ×0.82–0.90 | ×0.95–1.04 |
| **Tarde** | Media dificultad | ×1.00–1.12 | ×1.22–1.32 |
| **Noche** | Muchos, rápidos, con HP extra | ×1.28–1.48 | ×1.55–1.82 |

---

## 🛠️ Técnico

| Propiedad | Valor |
|---|---|
| Motor | Godot 4.7 |
| Resolución nativa | 320 × 480 (portrait) |
| Plataforma objetivo | Web (HTML5) |
| Lenguaje | GDScript 4 |
| Guardado | JSON en `user://as2_records.save` |

---

## 🚀 Cómo jugar (Web)

Abre `Android Squadron 2 - Godot Remake.html` en un navegador moderno.  
Compatible con teclado (WASD / flechas, Espacio para disparar, P/ESC para pausa) y control táctil.

---

## 📁 Estructura del proyecto

```
scripts/
├── Main.gd                  # Lógica principal del juego (~1600 líneas)
├── managers/
│   └── LevelConfig.gd       # Tabla de datos de los 9 niveles
└── ui/
    └── ResultFrames.gd      # Cálculo de frames para pantallas de resultado
scenes/
└── Main.tscn                # Escena principal
assets/                      # Sprites, fondos y audio
```

---

*Proyecto personal — del Android original al remake en Godot con ❤️*
