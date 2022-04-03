using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class TrailManager : MonoBehaviour
{
    [SerializeField]
    private float trailWidth = 0.3f;

    [SerializeField]
    private Transform[] transformPositions = {};

    [SerializeField]
    private GameObject trailSegmentPrefab;

    private List<Renderer> pooledRenderers = new List<Renderer>();

    private Vector3[] customPositions = {};

    private Vector3[] positions
    {
        get
        {
            // Use tranforms provided by Inspector, otherwise use custom position, filled by the SetCustomPositions method.
            if (this.transformPositions.Length > 0)
            {
                return this.transformPositions.Select(transformPosition => { return transformPosition.position; }).ToArray();
            }
            else
            {
                return this.customPositions;
            }
        }
    }

    private Vector3[] previousPositions = {};

    public void SetCustomPositions(Vector3[] customPositions)
    {
        this.customPositions = customPositions;
    }
    
    private void GenerateTrail()
    {
        if (this.positions.Length > 1)
        {
            for (var i = 1; i < this.positions.Length; i++)
            {
                Vector3 segmentStartingPoint = this.positions[i - 1];
                Vector3 segmentEndingPoint = this.positions[i];

                float segmentLength = Vector3.Distance(segmentStartingPoint, segmentEndingPoint);
                // Place the segment between the starting point and the end point
                Vector3 segmentWorldPosition = Vector3.Lerp(segmentStartingPoint, segmentEndingPoint, 0.5f);

                // Rotate the root game object so that it look from the starting point to the ending point
                // the child object, which has the renderer component, has already been rotated to face upward
                Quaternion segmentRotation = Quaternion.LookRotation(segmentEndingPoint - segmentStartingPoint, Vector3.up);

                Renderer trailRenderer = this.GetPooledRenderer(segmentWorldPosition, segmentRotation);
                Vector3 trailSegmentLocalScale = trailRenderer.transform.localScale;
                // Scale the child renderer along the x axis to span from starting point to ending point
                trailSegmentLocalScale.x = segmentLength;
                // Scale the child renderer along the y axis according to the given settings. This drives the size of the trail's symbols.
                trailSegmentLocalScale.y = this.trailWidth;
                trailRenderer.transform.localScale = trailSegmentLocalScale;

                // Pass the aspect ratio to the material so that it can correctly calculate the size of each symbol
                trailRenderer.material.SetFloat("_AspectRatio", trailSegmentLocalScale.x / trailSegmentLocalScale.y);
            }
        }
    }

    private Renderer GetPooledRenderer(Vector3 position, Quaternion rotation)
    {
        // This is a simple pooling approach to reduce the impact on performance in case of changes in size on the positions array.
        Renderer renderer = this.pooledRenderers.FirstOrDefault(renderer => { return renderer.transform.parent.gameObject.activeSelf == false; });
        if (renderer != default)
        {
            renderer.transform.parent.position = position;
            renderer.transform.parent.rotation = rotation;
            renderer.transform.parent.gameObject.SetActive(true);
            return renderer;
        }
        else
        {
            GameObject trailSegment = Instantiate(this.trailSegmentPrefab, position, rotation);
            Renderer newRenderer = trailSegment.GetComponentInChildren<Renderer>();
            this.pooledRenderers.Add(newRenderer);
            return newRenderer;
        }
    }

    private void PoolAllRenderers()
    {
        this.pooledRenderers.ForEach(renderer => renderer.transform.parent.gameObject.SetActive(false));
    }

    void Update()
    {
        // If any change occurs in the position array, redraw the trail
        if (false == Enumerable.SequenceEqual(this.previousPositions, this.positions))
        {
            this.previousPositions = this.positions;
            this.PoolAllRenderers();
            this.GenerateTrail();
        }
    }
}
