package dge.frontend.math;

typedef Point = { x:Float, y:Float };
typedef AABB = { minX:Float, minY:Float, maxX:Float, maxY:Float };

class BoundHelper {
    /**
     * Compute AABB for a rotated rectangle.
     * @param rectX   Top-left X of rectangle
     * @param rectY   Top-left Y of rectangle
     * @param w       Width
     * @param h       Height
     * @param angle   Rotation in degress(negative)
     * @param originX Normalized origin X (0 = left, 1 = right)
     * @param originY Normalized origin Y (0 = top, 1 = bottom)
     */
    public static function computeAABB(rectX:Float, rectY:Float, w:Float, h:Float, angle:Float, originX:Float, originY:Float):AABB {
        // pivot point in world coordinates
        var pivotX = rectX + originX * w;
        var pivotY = rectY + originY * h;
        angle = ((-angle) * Math.PI / 180);

        // rectangle corners before rotation (top-left convention)
        var corners = [
            {x: rectX,   y: rectY},     // top-left
            {x: rectX+w, y: rectY},     // top-right
            {x: rectX+w, y: rectY+h},   // bottom-right
            {x: rectX,   y: rectY+h}    // bottom-left
        ];

        var rotated:Array<Point> = [];

        for (corner in corners) {
            var dx = corner.x - pivotX;
            var dy = corner.y - pivotY;
            var xRot = pivotX + dx * Math.cos(angle) - dy * Math.sin(angle);
            var yRot = pivotY + dx * Math.sin(angle) + dy * Math.cos(angle);
            rotated.push({x: xRot, y: yRot});
        }

        // compute AABB
        var minX = Math.POSITIVE_INFINITY;
        var minY = Math.POSITIVE_INFINITY;
        var maxX = Math.NEGATIVE_INFINITY;
        var maxY = Math.NEGATIVE_INFINITY;

        for (p in rotated) {
            if (p.x < minX) minX = p.x;
            if (p.x > maxX) maxX = p.x;
            if (p.y < minY) minY = p.y;
            if (p.y > maxY) maxY = p.y;
        }

        return { minX:minX, minY:minY, maxX:maxX, maxY:maxY };
    }
}