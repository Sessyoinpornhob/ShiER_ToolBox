using System.Collections.Generic;
using UnityEngine;

public static class CirclePointsGenerator
{
    /// <summary>
    /// 计算单位圆上均匀分布的点，并允许调整点之间的间距。
    /// </summary>
    /// <param name="numPoints">需要生成的点的数量。</param>
    /// <param name="spacingFactor">用于调整点之间的间距的因子。1 表示均匀分布，值越大，点之间的间距越大。</param>
    /// <returns>返回单位圆上所有点的列表。</returns>
    public static List<Vector3> GetPointsOnUnitCircle(int numPoints, float spacingFactor = 1.0f)
    {
        List<Vector3> points = new List<Vector3>();

        // 每个点的角度间隔（弧度）
        float angleStep = spacingFactor * 2 * Mathf.PI / numPoints;

        for (int i = 0; i < numPoints; i++)
        {
            float angle = i * angleStep;
            float x = Mathf.Cos(angle);
            float y = Mathf.Sin(angle);
            points.Add(new Vector3(x, 0, y));
        }

        return points;
    }
}