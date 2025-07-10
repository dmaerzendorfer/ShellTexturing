using PrimeTween;
using UnityEngine;

public class ScrollingObjects : MonoBehaviour
{
    public TweenSettings<float> xPosTweenSettings;

    private Tween _xTween;

    private void Start()
    {
        _xTween = Tween.PositionX(gameObject.transform, xPosTweenSettings);
    }

    private void OnValidate()
    {
        if (Application.isPlaying)
        {
            _xTween.Stop();
            _xTween = Tween.PositionX(gameObject.transform, xPosTweenSettings);
        }
    }
}
