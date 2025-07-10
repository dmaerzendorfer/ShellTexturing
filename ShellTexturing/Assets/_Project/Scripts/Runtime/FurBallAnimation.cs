using PrimeTween;
using UnityEngine;

namespace _Project.Scripts.Runtime
{
    public class FurBallAnimation : MonoBehaviour
    {
        public TweenSettings<Quaternion> rotateTweenSettings;
        public TweenSettings<float> yPosTweenSettings;
        public TweenSettings<Vector3> scaleTweenSettings;

        private Tween _rotateTween;
        private Tween _yTween;
        private Tween _scaleTween;

        private void Start()
        {
            _scaleTween = Tween.Scale(gameObject.transform, scaleTweenSettings);
            _yTween = Tween.PositionY(gameObject.transform, yPosTweenSettings);
            _rotateTween = Tween.LocalRotation(gameObject.transform, rotateTweenSettings);
        }

        private void OnValidate()
        {
            if (Application.isPlaying)
            {
                _rotateTween.Stop();
                _rotateTween = Tween.LocalRotation(gameObject.transform, rotateTweenSettings);

                _yTween.Stop();
                _yTween = Tween.PositionY(gameObject.transform, yPosTweenSettings);

                _scaleTween.Stop();
                _scaleTween = Tween.Scale(gameObject.transform, scaleTweenSettings);
            }
        }
    }
}