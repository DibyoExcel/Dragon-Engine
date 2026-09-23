package dge.frontend.math;

typedef Point = { x:Float, y:Float };
typedef AABB = { minX:Float, minY:Float, maxX:Float, maxY:Float };

class BoundHelper {
    /**
     * Compute AABB for a rotated + origin rectangle.
     * @param rectX   Top-left X of rectangle
     * @param rectY   Top-left Y of rectangle
     * @param w       Width
     * @param h       Height
     * @param angle   Rotation in degress
     * @param originX Normalized origin X (0 = left, 1 = right)
     * @param originY Normalized origin Y (0 = top, 1 = bottom)
     */
    public static function computeAABB(rectX:Float, rectY:Float, w:Float, h:Float, angle:Float, originX:Float, originY:Float):AABB {
        if (angle == 0) return { minX: rectX, minY: rectY, maxX: rectX + w, maxY: rectY + h};
        var pivotX = rectX + originX * w;
        var pivotY = rectY + originY * h;

        var rad = -angle * (Math.PI / 180.0);
        var cos = Math.cos(rad);
        var sin = Math.sin(rad);

        var dx0 = rectX - pivotX;
        var dy0 = rectY - pivotY;
        var dx1 = dx0 + w;
        var dy1 = dy0 + h;

        var x1 = pivotX + dx0 * cos - dy0 * sin;
        var y1 = pivotY + dx0 * sin + dy0 * cos;

        var x2 = pivotX + dx1 * cos - dy0 * sin;
        var y2 = pivotY + dx1 * sin + dy0 * cos;

        var x3 = pivotX + dx1 * cos - dy1 * sin;
        var y3 = pivotY + dx1 * sin + dy1 * cos;

        var x4 = pivotX + dx0 * cos - dy1 * sin;
        var y4 = pivotY + dx0 * sin + dy1 * cos;

        var minX = Math.min(Math.min(x1, x2), Math.min(x3, x4));
        var maxX = Math.max(Math.max(x1, x2), Math.max(x3, x4));
        var minY = Math.min(Math.min(y1, y2), Math.min(y3, y4));
        var maxY = Math.max(Math.max(y1, y2), Math.max(y3, y4));

        return { minX: minX, minY: minY, maxX: maxX, maxY: maxY };
    }
}