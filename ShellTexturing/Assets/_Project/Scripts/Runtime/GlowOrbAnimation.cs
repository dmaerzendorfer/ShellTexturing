using System;
using PrimeTween;
using UnityEngine;

namespace _Project.Scripts.Runtime
{
    public class GlowOrbAnimation : MonoBehaviour
    {
        public TweenSettings<float> posTweenSettings;

        private Tween _tween;

        private void Start()
        {
            _tween = Tween.PositionY(gameObject.transform, posTweenSettings);
        }

        private void OnValidate()
        {
            if (Application.isPlaying)
            {
                _tween.Stop();
                _tween = Tween.PositionY(gameObject.transform, posTweenSettings);
            }
        }
    }
}