# Dotted Trail Renderer

**Dotted Trail Renderer** allows to create a path of animated circles defined by a given number of positions. This can be useful to show projectle trajectories in a Puzzle Bubble style.

## Requirements

- Unity 2020.3.16f1+
- Unity 2021.1.17f1+

What drives the requirements is the Package Requirements feature, that allows the DottedTrailSegment shader to correctly compile with the Built-In RP, avoiding errors due to missing URP packages.

## Compatibility

- Built-In Rendering Pipeline
- Universal Rendering Pipeline

## Get Started

- Drag the **TrailManager** prefab into the scene.
- Add the transforms that defines your path, in order, in the **Transform Positions** array of the TrailManager script. Alternatively, you can set your positions via script by calling the **SetCustomPosition** method in the TrailManager script.

When the game starts, the trail will be rendered and will update in case any changes happens to the positions array.

### TrailManager Properties

- **Trail Width**: define the width of the trail. Use this property to control the size of the circles.
- **Transform Positions**: allow to define your path through transforms.
- **Trail Segment Prefab**: the prefab that will be used to show a single segment of the path. Could be changed to use segment variants which renders materials that draws symbols other than the circle (see: **Future Improvements**).

### Dotted Trail Segment Material Properties

- **Dot Color**: color of the circles. Transparency is supported.
- **Between Dots Distance**: distance between the center of the circles.
- **Dot Speed**: speed of the dot animation along the trail. Set it to zero to exclued the animation altogether.

### Example

Check the **SampleScene** scene for an example. Press Play to see an example of a trail and see how interact with other opaques and transparents.

### Performance Considerations

- To draw the circle, the **length** function is used, which is quite expensive.
- Every time the positions change, the entire trail is recalculated. This could impact performance when changes are frequent (as it might happen with a projectle trajectory implementation). However, a **pooling** pattern has been used to reuse previously instantiated segments, to keep costs to a minimum.

### Future Improvements

- Create other shaders for different shapes for the trail (e.g.: dashes).
- Improve the TrailManager to filter out positions that are more or less along the same trajectory of the previous ones. This could happen in case the trajectory has been generated by physics simulation steps. This improvement could help to reduce the number of segments and improve both appearance and performances.