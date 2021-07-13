module poly2D
    
using Statistics, Devices, PyPlot, LazySets, ArchGDAL

"""
"""

function  checkConvex(V)
# Given a set of points determine if they form a convex polygon

    px=V[:,1];
    py=V[:,2];

    isConvex = false;

    numPoints = length(px);
    if numPoints < 4
        isConvex = true;
        return isConvex
    end

    # can determine if the polygon is convex based on the direction the angles
    # turn.  If all angles are the same direction, it is convex.
    v1 = [px[1] - px[end], py[1] - py[end]];
    v2 = [px[2] - px[1], py[2] - py[1]];
    signPoly = sign(det([v1'; v2']));

    # check subsequent vertices
    for k = 2:numPoints-1
        v1 = v2;
        v2 = [px[k+1] - px[k], py[k+1] - py[k]];
        curr_signPoly = sign(det([v1'; v2']));
        # check that the signs match
        if curr_signPoly != signPoly
            isConvex = false;
            return isConvex
        end
    end

    # check the last vectors
    v1 = v2;
    v2 = [px[1] - px[end], py[1] - py[end]];
    curr_signPoly = sign(det([v1'; v2']));
    if curr_signPoly != signPoly
        isConvex = false;
    else
        isConvex = true;
    end

    return isConvex
end


function createLine(p1,p2)

    # first input parameter is first point, and second input is the
    # second point.
    line = [p1[1] p1[2] p2[1]-p1[1] p2[2]-p1[2]];

end


function distanceMat(points1,points2)

    numPoints1=size(points1,1)
    numPoints2=size(points2,1)

    distMat=zeros(numPoints1,numPoints2)
    for i=1:numPoints1
        point_i=points1[i,:]
        for j=1:numPoints2
            point_j=points2[j,:]
            distMat[i,j]=sqrt(sum((point_i-point_j).^2))
        end
    end

    return distMat

end


function expandPolygon(V, dist)
    numVertices = size(V,1)
    poly = Devices.Polygon([Devices.Point(V[i,1],V[i,2]) for i=1:numVertices])
    poly_ = Devices.offset(poly, dist)
    
    poly__ = poly_[1].p
    numVertices_ = size(poly__,1)
    V_ = zeros(numVertices_,2)
    for i=1:numVertices_
        V_[i,1] = poly__[i][1]
        V_[i,2] = poly__[i][2]
    end

    V__ = poly2D.expandPolygonSides(V, dist, collect(1:numVertices))
    
    V_out = zeros(size(V__,1),2)
    posVec = zeros(size(V__,1),1)
    for i = 1:size(V__,1)
        for j = 1:size(V_,1)
            if sqrt(sum((V__[i,:] - V_[j,:]).^2)) <= 1
                V_out[i,:] =  V_[j,:]
                posVec[i] = j
            end
        end
    end
    pos = setdiff(collect(1:size(V_,1)), unique(posVec))

    if length(pos) >= 0
        V_out[V_out[:,1] .== 0,: ] .= V_[pos,:]
    end

    return V_out

end


function expandPolygonSide(poly_in, dist, edge)
    poly=copy(poly_in);

    # eventually copy first point at the end to ensure closed polygon
    if sum(poly[end, :] == poly[1,:]) != 2
        poly = [poly; poly[1,:]'];
    end

    # number of vertices of the polygon
    N = size(poly, 1)-1;

    # find lines parallel to polygon edges located at distance DIST
    lines = zeros(N, 4);
    for i = 1:N
        side = createLine(poly[i,:], poly[i+1,:]);
        if i==edge
            lines[i, 1:4] = parallelLine(side, dist);
        else
            lines[i, 1:4] = side;
        end
    end

    # compute intersection points of consecutive lines
    lines = [lines;lines[1,:]'];
    poly_out = zeros(N, 2);
    for i = 1:N
        pa1=lines[i,:];
        pa2=lines[i+1,:];
        poly_aux = intersectLines(pa1, pa2);
        poly_out[i,1:2] = poly_aux;
    end

    poly_out = [poly_out[end,:]'; poly_out[1:N-1,:]];

end


function expandPolygonSides(poly, sep, edges)

    numEdgesTotales = size(poly,1)
    conjuntoEdgesTotales = 1:numEdgesTotales
    conjuntoEdgesNoSeleccionados = setdiff(conjuntoEdgesTotales,edges)
    numEdges = length(edges);

    poly_ = copy(poly);

    if numEdges >= 1
        for i in edges
            poly_aux = expandPolygonSide(poly_, sep, i);
            poly_ = copy(poly_aux);
        end
        poly_out = poly_;
    end

    return poly_out
end



function inpoly_mat(points, poly, edge)

    nvrt = size(points,1);
    nnod = size(poly,1);
    nedg = size(edge,1);

    stat = falses(nvrt,1);
    bnds = falses(nvrt,1);
    
#----------------------------------- loop over polygon edges
    for epos = 1 : size(edge,1)
        inod = edge[epos,1] ;
        jnod = edge[epos,2] ;

    #------------------------------- calc. edge bounding-box
        yone = poly[inod,2];
        ytwo = poly[jnod,2];
        xone = poly[inod,1];
        xtwo = poly[jnod,1];
        
        xmin = min(xone, xtwo);
        xmax = max(xone, xtwo);
        
       
        ymin = yone;
        ymax = ytwo;
        
        ydel = ytwo - yone;
        xdel = xtwo - xone;

    #------------------------------- find top VERT(:,2)<YONE
        ilow = 1;
        iupp = nvrt;
        
        while (ilow < iupp - 1)    # binary search    
            imid = ilow + Int(floor((iupp-ilow) / 2));
            
            if (points[imid,2] < ymin)
                ilow = imid;
            else
                iupp = imid ;
            end
        end
        
        if (points[ilow,2] >= ymin)
            ilow = ilow - 1 ;
        end

    #------------------------------- calc. edge-intersection
        for jpos = ilow+1:nvrt
       
            if (bnds[jpos])
                 continue; 
            end
        
            xpos = points[jpos,1];
            ypos = points[jpos,2];
            
            if (ypos <= ymax)
                if (xpos >= xmin)
                    if (xpos <= xmax)
            
                #------------------- compute crossing number    
                    mul1 = ydel * (xpos - xone) ;
                    mul2 = xdel * (ypos - yone) ;
                    
                        if (ypos == yone &&  xpos == xone )
                            
                    #------------------- BNDS -- match about ONE
                            bnds[jpos]= true ;
                            stat[jpos]= true ;
                            
                        elseif (ypos == ytwo &&  xpos == xtwo )
                        
                    #------------------- BNDS -- match about TWO
                            bnds[jpos]= true ;
                            stat[jpos]= true ;
                        
                        elseif (mul1 < mul2)
                        
                            if (ypos >= yone && ypos <  ytwo)
                                
                        #------------------- advance crossing number
                                stat[jpos] = ~stat[jpos] ;
                            end
                        end
                
                    end
                else
                
                    if (ypos >= yone && ypos <  ytwo)
                #------------------- advance crossing number
                        stat[jpos] = !stat[jpos] ;
                    end
                
                end
            else
            
                break ;            # done -- due to the sort
            
            end
                    
        end

    end
    
    return stat, bnds
end


function inpoly(points, poly)

    nnod = size(poly,1);
    nvrt = size(points,1);

    edge = [(1:nnod-1) (2:nnod); [nnod 1]];
#----------------------------------- prune points using bbox
    mask =  (points[:,1] .>= minimum(poly[:,1])) .* (points[:,1] .<= maximum(poly[:,1])) .* (points[:,2] .>= minimum(poly[:,2])) .* (points[:,2] .<= maximum(poly[:,2]));
 
    vert = points[mask, :];

#----------------------------------- sort points via y-value
    swap = poly[edge[:,2],2] .< poly[edge[:,1],2];
         
    edge[swap,[1,2]] = edge[swap,[2,1]];    
  
    ivec = sortperm(points[:,2]);
    points = points[ivec,:];
        
    #-- call the native m-code version
   
    stat, bnds = inpoly_mat(points, poly, edge);
   
    stat[ivec] = stat;
    bnds[ivec] = bnds;

    #STAT[mask] = stat;
    #BNDS[mask] = bnds;

    STAT = stat;
    BNDS = bnds;
    
    return STAT, BNDS 
end


function intersectEdges(edge1, edge2)

    x1_ini  = edge1[1];
    y1_ini  = edge1[2];
    x1_fin  = edge1[3];
    y1_fin  = edge1[4];
    dx1 = x1_fin - x1_ini;
    dy1 = y1_fin - y1_ini;
    m1 = dy1 / dx1;

    x2_ini  = edge2[1];
    y2_ini  = edge2[2];
    x2_fin  = edge2[3];
    y2_fin  = edge2[4];
    dx2 = x2_fin - x2_ini;
    dy2 = y2_fin - y2_ini;
    m2 = dy2 / dx2;

    min_e1_x = min(x1_ini,x1_fin)
    min_e2_x = min(x2_ini,x2_fin)
    max_e1_x = max(x1_ini,x1_fin)
    max_e2_x = max(x2_ini,x2_fin)

    min_e1_y = min(y1_ini,y1_fin)
    min_e2_y = min(y2_ini,y2_fin)
    max_e1_y = max(y1_ini,y1_fin)
    max_e2_y = max(y2_ini,y2_fin)


# tolerance for precision
    tol = 1e-3; #1e-14;

# initialize result array
    x0  = 0;
    y0  = 0;

# indices of parallel edges
    par = abs(m1 - m2) < tol;

# Parallel edges have no intersection -> return [NaN NaN]
    if par
        x0 = NaN;
        y0 = NaN;
    end

# Process non parallel cases

    # compute intersection points of supporting lines
    delta = dx2 * dy1 - dx1 * dy2;
    x0 = ((y2_ini - y1_ini) * dx1 * dx2 + x1_ini * dy1 * dx2 - x2_ini * dy2 * dx1) / delta;
    y0 = ((x2_ini - x1_ini) * dy1 * dy2 + y1_ini * dx1 * dy2 - y2_ini * dx2 * dy1) / -delta;

    if  x0 < min_e1_x-tol || x0 < min_e2_x-tol || x0 > max_e1_x+tol || x0 > max_e2_x+tol || 
        y0 < min_e1_y-tol || y0 < min_e2_y-tol || y0 > max_e1_y+tol || y0 > max_e2_y+tol
        point = [NaN NaN];
#    elseif (x0-x1_ini)^2 + (y0-y1_ini)^2 <= 1  || (x0-x1_fin)^2 + (y0-y1_fin)^2 <= 1 ||  (x0-x2_ini)^2 + (y0-y2_ini)^2 <= 1  || (x0-x2_fin)^2 + (y0-y2_fin)^2  <= 1
#        point = [NaN NaN];
    else
        point = [x0 y0];    
    end

end


function expantLine(line, f)
    #intersectLines([x_0, y_0, x_1, y_1],2)
    x_0 = line[1]
    y_0 = line[2]
    x_1 = line[3]
    y_1 = line[4]
    m = (y_1 - y_0) / (x_1 - x_0)
    d = sqrt((y_1-y_0)^2+(x_1-x_0)^2)
    df = d*f
    y=x*m + a
end


function intersectLines(line1, line2)
    # intersectLines([x1_0, y1_0, x1_1, y1_1], [x2_0, y2_0, x2_1, y2_1])

    # extract tolerance
    tol = 1e-14;


    # Check parallel and colinear lines

    # coordinate differences of origin points
    dx = line2[1] - line1[1];
    dy = line2[2] - line1[2];

    # indices of parallel lines
    denom = line1[3] .* line2[4] - line2[3] .* line1[4];
    par = abs(denom) < tol;

    # initialize result array
    x0 = 0;
    y0 = 0;

    # initialize result for parallel lines
    if par
        x0 = Inf;
        y0 = Inf;
        point = [x0 y0];
        return;
    end

    # Extract coordinates of itnersecting lines

    # extract base coordinates of first lines
    x1 =  line1[1];
    y1 =  line1[2];
    dx1 = line1[3];
    dy1 = line1[4];

    # extract base coordinates of second lines
    x2 =  line2[1];
    y2 =  line2[2];
    dx2 = line2[3];
    dy2 = line2[4];

    # re-compute coordinate differences of origin points
    dx = line2[1] - line1[1];
    dy = line2[2] - line1[2];


    # Compute intersection points

    x0 = (x2 .* dy2 .* dx1 - dy .* dx1 .* dx2 - x1 .* dy1 .* dx2) ./ denom ;
    y0 = (dx .* dy1 .* dy2 + y1 .* dx1 .* dy2 - y2 .* dx2 .* dy1) ./ denom ;

    # concatenate result
    point = [x0 y0];
end


function intersectPoly2d(V1, V2)

    V1 = [V1; V1[1,:]'];
    V2 = [V2; V2[1,:]'];
    N1 = size(V1, 1)
    N2 = size(V2, 1)

    # Loop over segments of V1
    i=1
    X=[NaN NaN NaN NaN]
    for n1 = 1:N1-1
        for n2 = 1:N2-1
            e1 = [V1[n1,:]' V1[n1+1,:]'] 
            e2 = [V2[n2,:]' V2[n2+1,:]']
            pInt = intersectEdges(e1, e2)
            if abs(pInt[1])>0
                if i==1
                    X[:] = [n1 n2 pInt]
                else
                    X = [X; [n1 n2 pInt]]
                end
                i=i+1      
            end
        end
    end
    
    return X

end


function isPointInPolygon(points, V_)

    V=copy(V_);

    numPointsToCheck=size(points,1);
    A, b, c = vert2con(V);

    flagInPoly=[];
    for i=1:numPointsToCheck
        p_i=points[i,:];
        flagInPoly_=A*p_i.<b;
        flagInPoly_i=prod(flagInPoly_);
        push!(flagInPoly,flagInPoly_i);

    end

    return flagInPoly
end


function findNonConvexVert(Vin)

    V = copy(Vin);

    V_ = poly2D.expandPolygon(V, -.5)
    V_ch = poly2D.convHull(V_)

    flagNonConvex = isPointInPolygon(V, V_ch)

    idNonConv = collect(1:size(V,1))
    idNonConv = idNonConv[flagNonConvex .== true]

    return idNonConv
end


function isRectInPoly(rect,poly)

    pos_x = rect[1];
    pos_y = rect[2];
    largo_x = rect[3];
    largo_y = rect[4];
    theta = rect[5];

    Rmat = rotationMatrix(theta);
    cr = [pos_x; pos_y];
    p1 = (Rmat * ([pos_x; pos_y] - cr) + cr)';
    p2 = (Rmat * ([pos_x + largo_x; pos_y] - cr) + cr)';
    p3 = (Rmat * ([pos_x + largo_x; pos_y + largo_y] - cr) + cr)';
    p4 = (Rmat * ([pos_x; pos_y + largo_y] - cr) + cr)';

    if collect(inpoly(p1, poly)[1])[1] && collect(inpoly(p2, poly)[1])[1] && collect(inpoly(p3, poly)[1])[1] && 
        collect(inpoly(p4, poly)[1])[1] && !(intersectPoly2d([p1; p2; p3; p4], poly)[1,1]>0)
        return true
    else
        return false
    end

end


function lineAngle(line)

    # angle of one line with horizontal
    theta = mod(atan(line[4], line[3]) + 2*pi, 2*pi);

end


function parallelLine(line, dist)

    # use a distance. Compute position of point located at distance DIST on
    # the line orthogonal to the first one.
    point = pointOnLine([line[1] line[2] line[4] -line[3]], dist);

    res = [point' (line[3:4])'];
end




function pointOnLine(line, pos)

    angle = lineAngle(line);
    point = [line[1] + pos .* cos(angle), line[2] + pos .* sin(angle)];
    
end


function polyArea(V)

    if V != []
      X=V[:,1];
      Y=V[:,2];
      numPoints=size(X,1);
  
      area = 0;   # Accumulates area
      j = numPoints;
  
      for i = 1:numPoints
        area = area + (X[j]+X[i])*(Y[j]-Y[i]);
        j = i;  #j is previous vertex to i
      end
  
      return out=abs(area/2);
    else
      return out=0;
    end
end


function randomPointInPolygon(poly, nPts)

    # polygon extreme coordinates
    xmin = minimum(poly[:,1]);  xmax = maximum(poly[:,1]);
    ymin = minimum(poly[:,2]);  ymax = maximum(poly[:,2]);
    
    # compute size of box
    boxSizeX = xmax - xmin;
    boxSizeY = ymax - ymin;
    
    # allocate memory for result
    points = zeros(nPts, 2);
    
    # contains indices of remaining points to process
    ind = 1;
    
    # iterate until all points have been sampled within the polygon
    while ind<=nPts
        x = rand() .* boxSizeX .+ xmin;
        y = rand() .* boxSizeY .+ ymin;
        points[ind, 1] = x;
        points[ind, 2] = y;
        #isPointInPolygon
        if collect(inpoly(points[ind, :]', poly)[1])[1]
            ind=ind+1;
        end
    end
    
    return points

end


function randomPointInExtrude(poly, alt, nPts)

    # polygon extreme coordinates
    xmin = minimum(poly[:,1]);  xmax = maximum(poly[:,1]);
    ymin = minimum(poly[:,2]);  ymax = maximum(poly[:,2]);
    zmin = minimum(0);  zmax = maximum(alt);

    # compute size of box
    boxSizeX = xmax - xmin;
    boxSizeY = ymax - ymin;
    boxSizeZ = zmax - zmin;
    
    # allocate memory for result
    points = zeros(nPts, 3);
    
    # contains indices of remaining points to process
    ind = 1;
    
    # iterate until all points have been sampled within the polygon
    while ind<=nPts
        x = rand() .* boxSizeX .+ xmin;
        y = rand() .* boxSizeY .+ ymin;
        z = rand() .* boxSizeZ .+ zmin;
        points[ind, 1] = x;
        points[ind, 2] = y;
        points[ind, 3] = z;
        #isPointInPolygon
        if collect(inpoly(points[ind, 1:2]', poly)[1])[1]
            ind=ind+1;
        end
    end
    
    return points

end




function rotationMatrix(theta)
    R=[cos(theta) -sin(theta); sin(theta) cos(theta)];
end


function convHull(V)
    
    n = size(V,1)
    v = [[V[i,1], V[i,2]] for i=1:n]
    ch_v = LazySets.convex_hull(v)

    V_out = [0 0]; for i=1:length(ch_v); V_out=[V_out; ch_v[i]']; end; V_out = V_out[2:end,:]
    
    return V_out
end



function vert2con(V_)

    V = copy(V_);

    k = verticesConvHull(V);
    c = mean!([1. 1.], V[unique(k),:]);
    V = V-repeat(c,size(V,1),1);
    A = NaN*zeros(size(k,1),size(V,2));
    rc=0;
    for ix = 1:size(k,1)
        F = V[k[ix,:],:];
        #if rank(F, 1e-5) == size(F,1)
            rc=rc+1;
            A[rc,:]=F\ones(size(F,1),1);
        #end
    end
    A=A[1:rc,:];
    b=ones(size(A,1),1);
    b=b+A*c';

    return A,b,c

end


function plotScatter3d(x,y,z, fig=nothing, ax=nothing, ax_mat=nothing, color="red", marker="o", alpha=.3)

    plt = pyimport("matplotlib.pyplot")
    pyimport("mpl_toolkits.mplot3d")


    if fig === nothing
        pygui(true)

        fig = plt.figure()
        ax = fig[:add_subplot](111, projection = "3d")

        min_ax_x = minimum(x)
        min_ax_y = minimum(y)
        min_ax_z = minimum(z)
        max_ax_x = maximum(x)
        max_ax_y = maximum(y)
        max_ax_z = maximum(z)
    else
        min_ax_x = ax_mat[1,1]
        min_ax_y = ax_mat[2,1]
        min_ax_z = ax_mat[3,1]
        max_ax_x = ax_mat[1,2]
        max_ax_y = ax_mat[2,2]
        max_ax_z = ax_mat[3,2]
        min_ax_x = minimum([min_ax_x minimum(x)])
        min_ax_y = minimum([min_ax_y minimum(y)])
        min_ax_z = minimum([min_ax_z minimum(z)])
        max_ax_x = maximum([max_ax_x maximum(x)])
        max_ax_y = maximum([max_ax_y maximum(y)])
        max_ax_z = maximum([max_ax_z maximum(z)])
    
    end

    ax.set_xlim(min_ax_x, max_ax_x)
    ax.set_ylim(min_ax_y, max_ax_y)
    ax.set_zlim(min_ax_z, max_ax_z)

    ax[:scatter3D](x, y, z, color=color, marker=marker, alpha=alpha)
    
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")

    plt.show()

    ax_mat = [min_ax_x max_ax_x; min_ax_y max_ax_y; min_ax_z max_ax_z]
    
    return fig, ax, ax_mat
    
end


function angulosLados(V)
    x = V[:,1]
    x = [x;x[1]]
    y = V[:,2]
    y = [y;y[1]]
    dx = x[2:end] .- x[1:end - 1]
    dy = y[2:end] .- y[1:end - 1]

    theta = zeros(size(V, 1), 1)
    for i = 1:size(V, 1)
        if dy[i] > 0 && dx[i] > 00
            theta[i] = atan(dy[i] / dx[i])
        elseif dy[i] > 0 && dx[i] < 0
            theta[i] = (90 + 180 / pi * atan(abs(dx[i]) / dy[i]) ) * pi / 180
        elseif dy[i] < 0 && dx[i] < 0
            theta[i] = (180 + 180 / pi * atan(abs(dy[i]) / abs(dx[i])) ) * pi / 180
        elseif dy[i] < 0 && dx[i] > 0
            theta[i] = (270 + 180 / pi * atan(dx[i] / abs(dy[i])) ) * pi / 180
        else
            theta[i] = 0
        end
    end
    return theta
end


function rectangle(p, w, h, theta)
    R = poly2D.rotationMatrix(theta);
    x0 = p[1]
    y0 = p[2]
    cr = [x0; y0]
    p1 = R*([x0; y0]-cr) + cr
    p2 = R*([x0+w; y0]-cr) + cr
    p3 = R*([x0+w; y0+h]-cr) + cr
    p4 = R*([x0; y0+h]-cr) + cr
    
    V = [p1';p2';p3';p4']

    return V
end


function distPointLine(q, p1, p2)
    dist = sqrt(sum( ((q-p1) - ((q-p1)'*(p2-p1)) / ((p2-p1)'*(p2-p1)) * (p2-p1) ).^2))
    return dist
end

function pointAtDistFromLine(d, q, p1, p2)
    # Calcula la posicion del punto a una distancia d del punto q y 
    x1 = p1[1]; y1 = p1[2];
    x2 = p2[1]; y2 = p2[2];
    xq = q[1]; yq = q[2];

    xp_1 = xq + d/sqrt(1+((x2-x1)/(y2-y1))^2)
    yp_1 = yq - d*((x2-x1)/(y2-y1))/sqrt(1+((x2-x1)/(y2-y1))^2)
    p_1 = [xp_1 yp_1]

    xp_2 = xq - d/sqrt(1+((x2-x1)/(y2-y1))^2)
    yp_2 = yq + d*((x2-x1)/(y2-y1))/sqrt(1+((x2-x1)/(y2-y1))^2)
    p_2 = [xp_2 yp_2]

    return p_1, p_2
end

export  checkConvex, verticesConvHull, convHull, createLine, distanceMat, expandPolygonSide, expandPolygonSides, inpoly, inpoly_mat,
        intersectEdges, intersectLines, intersectPoly2d, isPointInPolygon, isRectInPoly, lineAngle, parallelLine,
        pointOnLine, polyArea, randomPointInPolygon, rotationMatrix, vert2con, plotScatter3d, findNonConvexVert,
        angulosLados, rectangle, distPointLine, pointAtDistFromLine
end
