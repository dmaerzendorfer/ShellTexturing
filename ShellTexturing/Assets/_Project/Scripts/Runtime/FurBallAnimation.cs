using PrimeTween;
using UnityEngine;

namespace _Project.Scripts.Runtime
{
    public class FurBallAnimation : MonoBehaviour
    {
        public TweenSettings<Quaternion> rotateTweenSettings;
        public TweenSettings<float> yPosTweenSettings;
        public Renderer renderer;

        private Tween _rotateTween;
        private Tween _yTween;
        private Sequence _furSequence;

        private Material _mat;
        private static readonly int BaseMove = Shader.PropertyToID("_BaseMove");

        private void Start()
        {
            _mat = renderer.material;
        }

        private void OnValidate()
        {
            if (Application.isPlaying)
            {
                _rotateTween.Stop();
                _rotateTween = Tween.LocalRotation(transform, rotateTweenSettings);

                _yTween.Stop();
                _yTween = Tween.LocalPositionY(gameObject.transform, yPosTweenSettings);

                _furSequence.Stop();
                _furSequence = Sequence.Create(-1, CycleMode.Restart, Ease.Linear).Chain(
                    Tween.Custom(0, 1f, 1f, (float t) =>
                    {
                        Vector4 movement = new Vector4(0, -(float)(9.81 - 9.81 * t), 0, 1);
                        _mat.SetVector(BaseMove, movement);
                    }, Ease.OutQuad)).Chain(
                    Tween.Custom(0, 1f, 1f, (float t) =>
                    {
                        Vector4 movement = new Vector4(0, (float)(0 + 9.81 * t), 0, 1);
                        _mat.SetVector(BaseMove, movement);
                    }, Ease.InQuad));
            }
        }
    }
}