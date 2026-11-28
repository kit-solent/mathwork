begin
	""" Rotates the given Vec2 by the given amount theta in radians
	"""
	function rot_vec2(vec2::Vec2, theta::Float64)::Vec2
		return [cos(theta) -sin(theta); sin(theta) cos(theta)] * vec2
	end

	""" Takes a line given as a vector of Vec2 points and returns a vector
	of line segments
	"""
	function segment_line(line::Line)::Vector{Segment}
		if length(line) < 2
			error("Attempting to segment a line with less that two points.")
		end

		segments::Vector{Segment} = []

		for i in 1:(length(line)-1)
			push!(segments, (line[i], line[i+1]))
		end

		return segments
	end

	""" Applies a step of the Koch snowflake process to a single
	DSegment. Takes the coordinates of the segment ends and
	returns a vector of DSegments representing the snowflake step.
    
	"""
	function step_segment(segment::Segment, normal::Vec2, randomize=true)::Vector{DSegment}
		normal = normalize(normal)

        # randomization
        if randomize
            normal = [-normal[1], -normal[2]]
        end

		# get the vector pointing along the length of the segment
		seg_vec = segment[2] - segment[1]

		# parameterise from t=0 to t=1
		line(t) = segment[1] + t*seg_vec

		# find the length of the segment
		seg_len = norm(seg_vec)

		# calculate the 5 coordinates forming the new line
		coord1 = line(0)
		coord2 = line(1/3) # the sqrt(3)/6 is explained in the book
		coord3 = line(1/2) + (sqrt(3)/6)*seg_len*normal
		coord4 = line(2/3)
		coord5 = line(1)

		# the first and last segments use the same normal vector but the
		# middle two require rotating it by +- pi/3 rad.
		norm2 = rot_vec2(normal, pi/3)
		norm3 = rot_vec2(normal, -pi/3)

		# now put together and return the 4 DSegments
		dseg1 = DSegment((Segment([coord1, coord2]), normal))
		dseg2 = DSegment((Segment([coord2, coord3]), norm2))
		dseg3 = DSegment((Segment([coord3, coord4]), norm3))
		dseg4 = DSegment((Segment([coord4, coord5]), normal))

		return [dseg1, dseg2, dseg3, dseg4]
	end

	""" Steps the given snowflake nflake forward by one step. This
	splits the line into segments and replaces each segment with four
	new segments as per the Koch snowflake rules and returns the result.
	"""
	function step_snowflake(nflake::Vector{DSegment})
		new_segments::Vector{DSegment} = []

		for segment in nflake
			append!(new_segments, step_segment(segment[1], segment[2]))
		end

		return new_segments
	end

	""" Converts a vector of Segments into a vector of points
	"""
	function segs2points(segments::Vector{Segment})::Line
		points::Line = []

		for segment in segments
			# add the first point of each segment
			push!(points, segment[1])
		end

		# now add the last point of the last segment
		push!(points, last(segments)[2])

		return points
	end

	""" Converts a vector of DSegments into a vector of Segments
	"""
	function dsegs2segments(segments::Vector{DSegment})::Vector{Segment}
		segs::Vector{Segment} = []

		for segment in segments
			# add the first point of each segment
			push!(segs, segment[1])
		end

		return segs
	end

	""" Converts a vector of DSegments into a vector of points
	"""
	function dsegs2points(segments::Vector{DSegment})::Vector{Vec2}
		segs2points(dsegs2segments(segments))
	end

	""" Converts a vector of DSegments into a vector of normal vectors
	"""
	function dsegs2norms(segments::Vector{DSegment})::Vector{Vec2}
		norms::Vector{Vec2} = []

		for segment in segments
			push!(norms, segment[2])
		end

		return norms
	end

	""" Generates a Koch curve to the given depth
	"""
	function generate_snowflake(depth::UInt32)::Vector{DSegment}
		# start by constructing the koch snowflake to the given depth
		# the snowflake is represented as a vector of points and normals
		snowflake::Vector{DSegment} = [DSegment((
			Segment((0.0, 0.0), (1.0, 0.0)), # line from the origin to x=1
			Vec2(0.0, 1.0) # the normal vector points straight up
		))]

		for i in 1:depth
			snowflake = step_snowflake(snowflake)
		end

		return snowflake
	end

	md""" This cell contains the functions used to generate the Koch curve
	"""
end

