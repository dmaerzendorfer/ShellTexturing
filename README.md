# ShellTexturing

Fur rendering with shell texturing in Unity URP. The mesh is drawn many times as stacked "shells" pushed out along the normals. Each shell throws away more noise-masked pixels than the one below, so strands appear.

## What's inside

- **`SimpleShell` + `Acerola/Shell`.** A component spawns `shellCount` shell objects and passes them their settings: length, density, noise range, thickness, curvature, displacement and occlusion. Based on [Acerola's shell texturing](https://github.com/GarrettGunnell/Shell-Texturing).
- **`Hecomi/Shells` and `Hecomi/LitShells`.** Unlit and lit URP shell shaders that loosely follow [hecomi's UnityFurURP](https://github.com/hecomi/UnityFurURP).
- **`MyBasicLit`.** A minimal URP lit HLSL shader, used as a reference.
- **Demo scene.** `FurScene` with animated fur balls, glow orbs and scrolling props.

## Getting started

1. Open the `ShellTexturing/` folder in **Unity 6000.0.41f1** (URP).
2. Open `Assets/_Project/Scenes/FurScene.unity` and press Play.
3. Change the fur look on the `SimpleShell` component or on the shell materials.

## Notes

A geometry-shader version was also tried, but it did not work.

Third-party: NaughtyAttributes.
