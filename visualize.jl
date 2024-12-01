using Plots
# for convex hull
using LazySets

function ternary_to_cartesian(r, g, b)
  x = b + r / 2
  y = (sqrt(3) / 2) * r
  return (x, y)
end

function plot_ternary(p, pts_3d::Vector{Any})

  tri_vertices_3d = [
    [1, 0, 0],
    [0, 1, 0],
    [0, 0, 1],
    [1, 0, 0],
  ]

  tri_vertices_2d = map(v -> ternary_to_cartesian(v[1], v[2], v[3]), tri_vertices_3d)

  tri_x = [v[1] for v in tri_vertices_2d]
  tri_y = [v[2] for v in tri_vertices_2d]

  plot!(p,
    tri_x, tri_y,
    label="",
    lw=2,
    color=:black
  )

  pts_2d = map(v -> ternary_to_cartesian(v[1], v[2], v[3]), pts_3d)
  pts_x = [v[1] for v in pts_2d]
  pts_y = [v[2] for v in pts_2d]

  scatter!(p,
    pts_x, pts_y,
    label="",
    color=:black,
    marker=:circle,
    markersize=4
  )

  corner_labels = [
    (0, 0, "g"),
    (1, 0, "b"),
    (0.5, sqrt(3) / 2, "r")
  ]

  for (x, y, lbl) in corner_labels

    # Adjust text position slightly to avoid overlapping with the triangle edges
    if lbl == "g"
      color = :green
      align = (:right, :top)
    elseif lbl == "b"
      color = :blue
      align = (:left, :top)
    elseif lbl == "r"
      color = :red
      align = (:center, :bottom)
    end
    annotate!(p, x, y, text(lbl, 12, color, halign=align[1], valign=align[2]))
  end

  function plot_convex_region!(p, points_2d)
    num_points = length(points_2d)

    if num_points == 1
      x_coords = [points_2d[1][1]]
      y_coords = [points_2d[1][2]]
      plot!(p, x_coords, y_coords, lw=2, color=:gray, label="")
    elseif num_points == 2
      x_coords = [points_2d[1][1], points_2d[2][1]]
      y_coords = [points_2d[1][2], points_2d[2][2]]
      plot!(p, x_coords, y_coords, lw=2, color=:gray, label="")
    elseif num_points >= 3
      hull = VPolygon([vcat(p...) for p in points_2d])
      plot!(p, hull, alpha=0.3, color=:gray)
    end
  end

  plot_convex_region!(p, pts_2d)
end

