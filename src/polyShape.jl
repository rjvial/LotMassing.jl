module polyShape
    
using ..poly2D, LotMassing, PyPlot, Devices, Clipper, PyCall


"""
"""
function extraeInfoPoly(ps)


    V = ps.Vertices[1]
    numLados = size(V, 1)

    vecLargoLados = zeros(numLados, 1)
    vecAnguloExt = zeros(numLados, 1)
    VecAnguloInt = zeros(numLados, 1)
    for i = 1:numLados
        if i == 1
            point_1 = V[numLados,:]
            point_2 = V[1,:]
            point_3 = V[2,:]
        elseif i == numLados
            point_1 = V[numLados - 1,:]
            point_2 = V[numLados,:]
            point_3 = V[1,:]
        else
            point_1 = V[i - 1,:]
            point_2 = V[i,:]
            point_3 = V[i + 1,:]
        end
        vecLargoLados[i,1] = sqrt(sum((point_3 - point_2).^2))
        vecAnguloExt[i,1] = atan((point_3[2] - point_2[2]) / (point_3[1] - point_2[1]))
        tramo1 = point_1 - point_2
        tramo2 = point_3 - point_2
        VecAnguloInt[i,1] = acos(sum(tramo1 .* tramo2) / sqrt(sum(tramo1 .* tramo1)) / sqrt(sum(tramo2 .* tramo2)))
    end

    matLargoDiag = zeros(numLados, numLados)
    for i = 1:numLados
        for j = 1:numLados
            if i != j
                point_1 = V[i,:]
                point_2 = V[j,:]
                matLargoDiag[i,j] = sqrt(sum((point_2 - point_1).^2))
            end
            
        end
    end

    return vecLargoLados[:,1], vecAnguloExt[:,1], VecAnguloInt[:,1], matLargoDiag

end


function isPolyConvex(ps)
    # Given a set of points determine if they form a convex polygon

    numRegiones = ps.NumRegions
    isConvexVec = Bool.(zeros(1, numRegiones))
    for j = 1:numRegiones

        V_j = ps.Vertices[j]

        isConvexVec[j] = poly2D.checkConvex(V_j)
    end
        
    return isConvexVec
end
    

function isPolyInPoly(ps_s, ps)

    ps_r = polyDifference_v3(ps_s, ps)

    if polyArea_v2(ps_r) < .01
        return true
    else
        return false
    end


end


function plotPolyshape(ps, fig=nothing, ax=nothing, min_ax=nothing, max_ax=nothing, color="red", alpha=1)
    patch = pyimport("matplotlib.patches")
    numRegions = ps.NumRegions

    for i = 1:numRegions
        V_i = ps.Vertices[i]

        if fig === nothing
            pygui(true)

            fig = plt.figure()
            ax = fig.add_subplot(1, 1, 1)

            min_ax = minimum([minimum(V_i[:,1]) minimum(V_i[:,2])])
            max_ax = maximum([maximum(V_i[:,1]) maximum(V_i[:,2])])
        else
            min_ax = minimum([min_ax minimum(V_i[:,1]) minimum(V_i[:,2])])
            max_ax = maximum([max_ax maximum(V_i[:,1]) maximum(V_i[:,2])])
        end

        ax.set_xlim(min_ax, max_ax)
        ax.set_ylim(min_ax, max_ax)
        ax.set_aspect("equal")
        grid("on")

        polygon = patch.Polygon(V_i, true, color=color, alpha=alpha)
        ax.add_patch(polygon)
    
    end

    return fig, ax, min_ax, max_ax
    
end



function plotPatch3d(V, simplices, fig=nothing, ax=nothing, ax_mat=nothing, fc="blue", a=1)

    plt = pyimport("matplotlib.pyplot")
    mpath = pyimport("matplotlib.path") 
    mpatches = pyimport("matplotlib.patches")
    art3d = pyimport("mpl_toolkits.mplot3d.art3d")
    pyimport("mpl_toolkits.mplot3d")

    numSimplices = length(simplices)

    if ax_mat !== nothing
        min_ax_x = ax_mat[1,1]
        min_ax_y = ax_mat[2,1]
        min_ax_z = ax_mat[3,1]
        max_ax_x = ax_mat[1,2]
        max_ax_y = ax_mat[2,2]
        max_ax_z = ax_mat[3,2]
    else
        min_ax_x = 0
        min_ax_y = 0
        min_ax_z = 0
        max_ax_x = 0
        max_ax_y = 0
        max_ax_z = 0
    end

    verts = [];
    if fig === nothing
        pygui(true)

        fig = plt.figure()
        ax = fig.gca(projection="3d")

        min_ax_x = minimum(V[:,1])
        min_ax_y = minimum(V[:,2])
        min_ax_z = minimum(V[:,3])
        max_ax_x = maximum(V[:,1])
        max_ax_y = maximum(V[:,2])
        max_ax_z = maximum(V[:,3])
    else
        min_ax_x = ax_mat[1,1]
        min_ax_y = ax_mat[2,1]
        min_ax_z = ax_mat[3,1]
        max_ax_x = ax_mat[1,2]
        max_ax_y = ax_mat[2,2]
        max_ax_z = ax_mat[3,2]
        min_ax_x = minimum([min_ax_x minimum(V[:,1])])
        min_ax_y = minimum([min_ax_y minimum(V[:,2])])
        min_ax_z = minimum([min_ax_z minimum(V[:,3])])
        max_ax_x = maximum([max_ax_x maximum(V[:,1])])
        max_ax_y = maximum([max_ax_y maximum(V[:,2])])
        max_ax_z = maximum([max_ax_z maximum(V[:,3])])
    end

    for i = 1:numSimplices
        simplex_i = simplices[i]
        V_i = V[simplex_i,:]

        if maximum(V_i[:,3]) - minimum(V_i[:,3]) >= 0.1
            push!(verts, V_i)
        end
    end
    ax.add_collection3d(art3d.Poly3DCollection(verts, facecolors=fc, linewidths=0.1, edgecolors=fc, alpha=a))

    ax.set_xlim(min_ax_x, max_ax_x)
    ax.set_ylim(min_ax_y, max_ax_y)
    ax.set_zlim(min_ax_z, max_ax_z)


    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")  
    plt.show()

    ax_mat = [min_ax_x max_ax_x; min_ax_y max_ax_y; min_ax_z max_ax_z]

    return fig, ax, ax_mat

end




function plotPolyshape3d_v1(ps, h=nothing, fig=nothing, ax=nothing, fc="blue", a=1)

    plt = pyimport("matplotlib.pyplot")
    mpath = pyimport("matplotlib.path") 
    mpatches = pyimport("matplotlib.patches")
    art3d = pyimport("mpl_toolkits.mplot3d.art3d")
    pyimport("mpl_toolkits.mplot3d")


    numRegions = ps.NumRegions

    for i = 1:numRegions
        V_i = ps.Vertices[i]
        numVerticesTotales, numDim = size(V_i);

        if fig === nothing
            pygui(true)

            fig = plt.figure()
            ax = fig.gca(projection="3d")
        end


        if numDim == 3

            conjuntoAlturas = unique(V_i[:,3])
            numAlturas = length(conjuntoAlturas)
    
            numVerticesBase = Int(round(numVerticesTotales / numAlturas));

            for k = 2:numAlturas

                x1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),1];
                y1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),2];
                z1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),3];

                x2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,1];
                y2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,2];
                z2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,3];

                verts = [];

                for j = 1:numVerticesBase
                    if j == numVerticesBase
                        j0 = j;
                        j1 = 1;
                    else
                        j0 = j;
                        j1 = j + 1;
                    end
                    x1 = x1vec[j0];
                    x2 = x1vec[j1];
                    x3 = x2vec[j1];
                    x4 = x2vec[j0];
    
                    y1 = y1vec[j0];
                    y2 = y1vec[j1];
                    y3 = y2vec[j1];
                    y4 = y2vec[j0];
    
                    z1 = z1vec[j0];
                    z2 = z1vec[j1];
                    z3 = z2vec[j1];
                    z4 = z2vec[j0];
    
                    vert = [[x1,y1,z1],
                    [x2,y2,z2], 
                    [x3,y3,z3], 
                    [x4,y4,z4]];
            
            
                    push!(verts, vert) 
    
                end
        
                ax.add_collection3d(art3d.Poly3DCollection(verts, facecolors=fc, linewidths=.4, edgecolors="k", alpha=a))
            end

        else
            numVerticesBase = Int(numVerticesTotales);

            V_i = [V_i h .* ones(numVerticesTotales, 1)]

            verts_ = [];
            for j = 1:numVerticesTotales
                vert = [V_i[j,1],V_i[j,2],V_i[j,3]];
                push!(verts_, vert) 
            end
            verts = [verts_]

            ax.add_collection3d(art3d.Poly3DCollection(verts, facecolors=fc, linewidths=.4, edgecolors="k", alpha=a))
        
        end

        ax.set_xlabel("X")
        ax.set_ylabel("Y")
        ax.set_zlabel("Z")
    end
    
    plt.show()


    return fig, ax

end


function plotPolyshape3d_v2(ps, h=nothing, fig=nothing, ax=nothing, ax_mat=nothing, fc="blue", a=1)

    plt = pyimport("matplotlib.pyplot")
    mpath = pyimport("matplotlib.path") 
    mpatches = pyimport("matplotlib.patches")
    art3d = pyimport("mpl_toolkits.mplot3d.art3d")
    pyimport("mpl_toolkits.mplot3d")


    numRegions = ps.NumRegions
    if ax_mat !== nothing
        min_ax_x = ax_mat[1,1]
        min_ax_y = ax_mat[2,1]
        min_ax_z = ax_mat[3,1]
        max_ax_x = ax_mat[1,2]
        max_ax_y = ax_mat[2,2]
        max_ax_z = ax_mat[3,2]
    else
        min_ax_x = 0
        min_ax_y = 0
        min_ax_z = 0
        max_ax_x = 0
        max_ax_y = 0
        max_ax_z = 0
    end

    for i = 1:numRegions
        V_i = ps.Vertices[i]
        numVerticesTotales, numDim = size(V_i);

        if fig === nothing
            pygui(true)

            fig = plt.figure()
            ax = fig.gca(projection="3d")

            if numDim == 3
                min_ax_x = minimum(V_i[:,1])
                min_ax_y = minimum(V_i[:,2])
                min_ax_z = minimum(V_i[:,3])
                max_ax_x = maximum(V_i[:,1])
                max_ax_y = maximum(V_i[:,2])
                max_ax_z = maximum(V_i[:,3])
            else
                min_ax_x = minimum(V_i[:,1])
                min_ax_y = minimum(V_i[:,2])
                max_ax_x = maximum(V_i[:,1])
                max_ax_y = maximum(V_i[:,2])
            end

        else
            if numDim == 3
                min_ax_x = ax_mat[1,1]
                min_ax_y = ax_mat[2,1]
                min_ax_z = ax_mat[3,1]
                max_ax_x = ax_mat[1,2]
                max_ax_y = ax_mat[2,2]
                max_ax_z = ax_mat[3,2]
                min_ax_x = minimum([min_ax_x minimum(V_i[:,1])])
                min_ax_y = minimum([min_ax_y minimum(V_i[:,2])])
                min_ax_z = minimum([min_ax_z minimum(V_i[:,3])])
                max_ax_x = maximum([max_ax_x maximum(V_i[:,1])])
                max_ax_y = maximum([max_ax_y maximum(V_i[:,2])])
                max_ax_z = maximum([max_ax_z maximum(V_i[:,3])])
            else
                min_ax_x = ax_mat[1,1]
                min_ax_y = ax_mat[2,1]
                max_ax_x = ax_mat[1,2]
                max_ax_y = ax_mat[2,2]
                min_ax_x = minimum([min_ax_x minimum(V_i[:,1])])
                min_ax_y = minimum([min_ax_y minimum(V_i[:,2])])
                max_ax_x = maximum([max_ax_x maximum(V_i[:,1])])
                max_ax_y = maximum([max_ax_y maximum(V_i[:,2])])
            end
        end


        if numDim == 3

            conjuntoAlturas = unique(V_i[:,3])
            numAlturas = length(conjuntoAlturas)
    
            numVerticesBase = Int(round(numVerticesTotales / numAlturas));

            for k = 2:numAlturas
                ax.set_xlim(min_ax_x, max_ax_x)
                ax.set_ylim(min_ax_y, max_ax_y)
                ax.set_zlim(min_ax_z, max_ax_z)

                x1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),1];
                y1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),2];
                z1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),3];

                x2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,1];
                y2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,2];
                z2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,3];

                verts = [];

                for j = 1:numVerticesBase
                    if j == numVerticesBase
                        j0 = j;
                        j1 = 1;
                    else
                        j0 = j;
                        j1 = j + 1;
                    end
                    x1 = x1vec[j0];
                    x2 = x1vec[j1];
                    x3 = x2vec[j1];
                    x4 = x2vec[j0];
    
                    y1 = y1vec[j0];
                    y2 = y1vec[j1];
                    y3 = y2vec[j1];
                    y4 = y2vec[j0];
    
                    z1 = z1vec[j0];
                    z2 = z1vec[j1];
                    z3 = z2vec[j1];
                    z4 = z2vec[j0];
    
                    vert = [[x1,y1,z1],
                    [x2,y2,z2], 
                    [x3,y3,z3], 
                    [x4,y4,z4]];
            
            
                    push!(verts, vert) 
    
                end
                collection = art3d.Poly3DCollection(verts, facecolors=fc, alpha=a, linewidths=.4, edgecolors="k")
                ax.add_collection3d(collection)
            end

        else
            numVerticesBase = Int(numVerticesTotales);

            ax.set_xlim(min_ax_x, max_ax_x)
            ax.set_ylim(min_ax_y, max_ax_y)

            V_i = [V_i h .* ones(numVerticesTotales, 1)]

            verts_ = [];
            for j = 1:numVerticesTotales
                vert = [V_i[j,1],V_i[j,2],V_i[j,3]];
                push!(verts_, vert) 
            end
            verts = [verts_]

            collection = art3d.Poly3DCollection(verts, facecolors=fc, alpha=a, linewidths=.4, edgecolors="k")
            ax.add_collection3d(collection)
        end

        ax.set_xlabel("X")
        ax.set_ylabel("Y")
        ax.set_zlabel("Z")
    end
    
    plt.show()

    ax_mat = [min_ax_x max_ax_x; min_ax_y max_ax_y; min_ax_z max_ax_z]

    fig, ax, ax_mat

end


function plotPolyshape3d_v3(ps, h=nothing, fig=nothing, ax=nothing, ax_mat=nothing, fc="blue", a=0.25)

    plt = pyimport("matplotlib.pyplot")
    mpath = pyimport("matplotlib.path") 
    mpatches = pyimport("matplotlib.patches")
    art3d = pyimport("mpl_toolkits.mplot3d.art3d")
    pyimport("mpl_toolkits.mplot3d")


    numRegions = ps.NumRegions
    
    if ax_mat === nothing
        min_ax = 0
        max_ax = 0
    else
        min_ax = ax_mat[1]
        max_ax = ax_mat[2]
    end

    for i = 1:numRegions
        V_i = ps.Vertices[i]
        numVerticesTotales, numDim = size(V_i);

        if fig === nothing
            pygui(true)

            fig = plt.figure()
            ax = fig.gca(projection="3d")

            if numDim == 3
                min_ax = minimum([minimum(V_i[:,1]) minimum(V_i[:,2]) minimum(V_i[:,3])])
                max_ax = maximum([maximum(V_i[:,1]) maximum(V_i[:,2]) maximum(V_i[:,3])])
            else
                min_ax = minimum([minimum(V_i[:,1]) minimum(V_i[:,2])])
                max_ax = maximum([maximum(V_i[:,1]) maximum(V_i[:,2])])
            end

        else
            if numDim == 3
                min_ax = minimum([min_ax minimum(V_i[:,1]) minimum(V_i[:,2]) minimum(V_i[:,3])])
                max_ax = maximum([max_ax maximum(V_i[:,1]) maximum(V_i[:,2]) maximum(V_i[:,3])])
            else
                min_ax = minimum([min_ax minimum(V_i[:,1]) minimum(V_i[:,2])])
                max_ax = maximum([max_ax maximum(V_i[:,1]) maximum(V_i[:,2])])
            end
        end

        ax.set_xlim(min_ax, max_ax)
        ax.set_ylim(min_ax, max_ax)
        ax.set_zlim(max(0, min_ax), max_ax)

        if numDim == 3

            conjuntoAlturas = unique(V_i[:,3])
            numAlturas = length(conjuntoAlturas)
    
            numVerticesBase = Int(round(numVerticesTotales / numAlturas));

            for k = 2:numAlturas

                x1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),1];
                y1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),2];
                z1vec = V_i[numVerticesBase * (k - 2) + 1:numVerticesBase * (k - 1),3];

                x2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,1];
                y2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,2];
                z2vec = V_i[numVerticesBase * (k - 1) + 1:numVerticesBase * k,3];

                verts = [];

                for j = 1:numVerticesBase
                    if j == numVerticesBase
                        j0 = j;
                        j1 = 1;
                    else
                        j0 = j;
                        j1 = j + 1;
                    end
                    x1 = x1vec[j0];
                    x2 = x1vec[j1];
                    x3 = x2vec[j1];
                    x4 = x2vec[j0];
    
                    y1 = y1vec[j0];
                    y2 = y1vec[j1];
                    y3 = y2vec[j1];
                    y4 = y2vec[j0];
    
                    z1 = z1vec[j0];
                    z2 = z1vec[j1];
                    z3 = z2vec[j1];
                    z4 = z2vec[j0];
    
                    vert = [[x1,y1,z1],
                    [x2,y2,z2], 
                    [x3,y3,z3], 
                    [x4,y4,z4]];
            
            
                    push!(verts, vert) 
    
                end
        
                ax.add_collection3d(art3d.Poly3DCollection(verts, facecolors=fc, linewidths=.4, edgecolors="k", alpha=a))
            end

        else
            numVerticesBase = Int(numVerticesTotales);


            V_i = [V_i h .* ones(numVerticesTotales, 1)]

            verts_ = [];
            for j = 1:numVerticesTotales
                vert = [V_i[j,1],V_i[j,2],V_i[j,3]];
                push!(verts_, vert) 
            end
            verts = [verts_]

            ax.add_collection3d(art3d.Poly3DCollection(verts, facecolors=fc, linewidths=.4, edgecolors="k", alpha=a))
        
        end

        ax.set_xlabel("X")
        ax.set_ylabel("Y")
        ax.set_zlabel("Z")
    end
    
    plt.show()

    ax_mat = [min_ax max_ax]

    fig, ax, ax_mat

end


function plotPolyshape3d_v4(vec_ps, vec_h, fig=nothing, ax=nothing, ax_mat=nothing, fc="red", a=0.1)
    numAlturas = length(vec_h)
    for i = 1:numAlturas
        ps_i = vec_ps[i]
        h_i = vec_h[i]
        fig, ax, ax_mat = polyShape.plotPolyshape3d_v3(ps_i, h_i, fig, ax, ax_mat, fc, a)
    end
    return fig, ax, ax_mat

end

#function plotPolyshape3d_v1(ps, h=nothing, fig=nothing, ax=nothing, fc="blue", a=1)
#function plotPolyshape3d_v2(ps, h=nothing, fig=nothing, ax=nothing, ax_mat=nothing, fc="blue", a=1)
#function plotPolyshape3d_v3(ps, h=nothing, fig=nothing, ax=nothing, ax_mat=nothing, fc="blue", a=0.25)
#function plotPolyshape3d_v4(vec_ps, vec_h, fig=nothing, ax=nothing, ax_mat=nothing, fc="red", a=0.1)
function plotPolyshape3d_v5(ps_volteor, matConexionVertices, vecVertices, fig=nothing, ax=nothing, ax_mat=nothing, fc="red", a=0.25)

    plt = pyimport("matplotlib.pyplot")
    mpath = pyimport("matplotlib.path") 
    mpatches = pyimport("matplotlib.patches")
    art3d = pyimport("mpl_toolkits.mplot3d.art3d")
    pyimport("mpl_toolkits.mplot3d")
    
    if ax_mat === nothing
        min_ax = 0
        max_ax = 0
    else
        min_ax = ax_mat[1]
        max_ax = ax_mat[2]
    end

    V_ = ps_volteor.Vertices[1]
    numVerticesTotales, numDim = size(V_);

    if fig === nothing
        pygui(true)

        fig = plt.figure()
        ax = fig.gca(projection="3d")

        min_ax = minimum([minimum(V_[:,1]) minimum(V_[:,2]) minimum(V_[:,3])])
        max_ax = maximum([maximum(V_[:,1]) maximum(V_[:,2]) maximum(V_[:,3])])

    else
        min_ax = minimum([min_ax minimum(V_[:,1]) minimum(V_[:,2]) minimum(V_[:,3])])
        max_ax = maximum([max_ax maximum(V_[:,1]) maximum(V_[:,2]) maximum(V_[:,3])])
    end

    ax.set_xlim(min_ax, max_ax)
    ax.set_ylim(min_ax, max_ax)
    ax.set_zlim(max(0, min_ax), max_ax)

    conjuntoAlturas = unique(V_[:,3])
    numAlturas = length(conjuntoAlturas)

    numVerticesBase = Int(round(numVerticesTotales / numAlturas));

    for k = 1:numAlturas - 1

        verts = [];

        for j = 1:length(vecVertices[k])
            if j == length(vecVertices[k])
                jl0 = Int.(vecVertices[k][j])
                jl1 = Int.(vecVertices[k][1])
            else
                jl0 = Int.(vecVertices[k][j])
                jl1 = Int.(vecVertices[k][j + 1])
            end
            x1 = V_[jl0,1]; y1 = V_[jl0,2]; z1 = V_[jl0,3];
            x2 = V_[jl1,1]; y2 = V_[jl1,2]; z2 = V_[jl1,3];
            ju0 = Int.(matConexionVertices[matConexionVertices[:,1] .== jl0,2])[1]
            ju1 = Int.(matConexionVertices[matConexionVertices[:,1] .== jl1,2])[1]

            x3 = V_[ju1,1]; y3 = V_[ju1,2]; z3 = V_[ju1,3];
            x4 = V_[ju0,1]; y4 = V_[ju0,2]; z4 = V_[ju0,3];

            vert = [[x1,y1,z1],
            [x2,y2,z2], 
            [x3,y3,z3], 
            [x4,y4,z4]];
    
            push!(verts, vert) 

        end

        ax.add_collection3d(art3d.Poly3DCollection(verts, facecolors=fc, linewidths=.06, edgecolors="k", alpha=a))
    end

    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")

    plt.show()

    ax_mat = [min_ax max_ax]

    fig, ax, ax_mat

end



function polyArea_v2(ps)
    numRegions = ps.NumRegions
    if numRegions >= 1
        vecArea = zeros(numRegions, 1)
        for i = 1:numRegions
            V_i = ps.Vertices[i]
            vecArea[i] = poly2D.polyArea(V_i)
        end

        out = sum(vecArea)
    else
        out = 0
    end
end


function polyShape2constraints(ps)

    V = copy(ps.Vertices[1])

    if !poly2d.checkConvex(V)
        ps_sub, SP = nonconv2sumofconv_v2(ps)
    else
        ps_sub = ps
    end

    CD  = Array{ConstraintData,1};
    for f = 1:ps_sub.NumRegions
            
        V = copy(ps_sub.Vertices[f]);

        k = poly2d.convhull(V);
        c = mean!([1. 1.], V[unique(k),:]);
        V = V - repeat(c, size(V, 1), 1);

        A  = NaN * zeros(size(V, 1), size(V, 2));
        K  = NaN * zeros(size(V, 1), size(V, 2));
        rc = 0;
        for ix = 1:size(V, 1)
            if ix == size(V, 1)
                k = [ix,1]
                F = V[k,:];
            else
                k = [ix,ix + 1]
                F = V[k,:];
            end
            rc = rc + 1;
            A[rc,:] = F \ ones(size(F, 1), 1);
            K[rc,:] = k;
        end
        A = A[1:rc,:];
        b = ones(size(A, 1), 1);
        b = b + A * c';
            
        SP_f = SP[f].points
        norm = zeros(size(A, 1), 2)
        for j = 1:size(A, 1)
            norm[j,:] = A[j,:] ./ sqrt(sum(A[j,:].^2))
        end
        if f == 1 
            CD = Array{ConstraintData,1}([ConstraintData(V, [SP_f[Int.(K[:,1])] SP_f[Int.(K[:,2])]], A, [], norm)]);
        else
            push!(CD, ConstraintData(V, [SP_f[Int.(K[:,1])] SP_f[Int.(K[:,2])]], A, [], norm));
        end   
    end

    return CD

end


function reversePath(V)
    V_ = copy(V)
    numVertices = size(V_, 1)
    V_out = zeros(numVertices, 2)
    for i = 1:numVertices
        V_out[end - i + 1,:] = V_[i,:]
    end
    return V_out
end


function polyOrientation(ps)

    V = ps.Vertices[1]
    numVertices = size(V, 1)

    poly = Devices.Polygon([Devices.Point(V[i,1], V[i,2]) for i = 1:numVertices])

    is_ccw = Devices.Polygons.orientation(poly)

    return is_ccw
end


function polyUnion(ps_s, ps_c)

    # if length(ps_s.Vertices) >= 1
    V_s = ps_s.Vertices[1]
    numVertices_s = size(V_s, 1)

    V_c = ps_c.Vertices[1]
    numVertices_c = size(V_c, 1)

    poly_s = Devices.Polygon([Devices.Point(V_s[i,1], V_s[i,2]) for i = 1:numVertices_s])
    poly_c = Devices.Polygon([Devices.Point(V_c[i,1], V_c[i,2]) for i = 1:numVertices_c])
    poly_ = Devices.Polygons.clip(Clipper.ClipTypeUnion, poly_s, poly_c)

    numRegiones = length(poly_)
    ps_out = PolyShape([], numRegiones)
    for k = 1:numRegiones
        poly_k = poly_[k].p
        numVertices_k = size(poly_k, 1)
        V_k = zeros(numVertices_k, 2)
        for i = 1:numVertices_k
            V_k[i,1] = poly_k[i][1]
            V_k[i,2] = poly_k[i][2]
        end
        ps_out.Vertices = push!(ps_out.Vertices, V_k)
    end
    ps_out.NumRegions = length(ps_out.Vertices)
    return ps_out
    # else
    #    return ps_s
    # end

end


function polyUnion_v2(ps_s_, ps_c_)

    ps_s = PolyShape([], 0)
    ps_s.Vertices = copy(ps_s_.Vertices)
    ps_s.NumRegions = length(ps_s_.Vertices)

    ps_c = PolyShape([], 0)
    ps_c.Vertices = copy(ps_c_.Vertices)
    ps_c.NumRegions = length(ps_c_.Vertices)

    numRegiones_s = ps_s.NumRegions
    numRegiones_c = ps_c.NumRegions

    matUnion = zeros(numRegiones_s, numRegiones_c)
    matPolyunions = Array{PolyShape,2}(undef, numRegiones_s, numRegiones_c)
    vecReg_s_ = []
    vecReg_c_ = []

    if length(ps_s.Vertices) == 0
        ps_r = ps_c
    elseif length(ps_c.Vertices) == 0
        ps_r = ps_s
    else
        for i = 1:numRegiones_s
            ps_s_i = PolyShape([ps_s.Vertices[i]], 1)
            for j = 1:numRegiones_c
                ps_c_j = PolyShape([ps_c.Vertices[j]], 1)
                ps_ij = polyUnion(ps_s_i, ps_c_j)
                matUnion[i,j] = 1 * (ps_ij.NumRegions >= 1)
                if matUnion[i,j] == 1
                    vecReg_s_ = unique([vecReg_s_; i])
                    vecReg_c_ = unique([vecReg_c_; j])
                end
                matPolyunions[i,j] = ps_ij
            end        
        end

        vecReg_s = [i for i = 1:numRegiones_s]
        vecReg_c = [j for j = 1:numRegiones_c]
        vecRegSep_s = setdiff(vecReg_s, vecReg_s_)
        vecRegSep_c = setdiff(vecReg_c, vecReg_c_)

        ps_r = PolyShape([], 0)
        for i = 1:numRegiones_s
            for j = 1:numRegiones_c
                if matUnion[i,j] == 1
                    if ps_r.NumRegions == 0
                        ps_r = matPolyunions[i,j]
                    else
                        ps_r = polyUnion(ps_r, matPolyunions[i,j])
                    end
                end
            end
        end

        for i in vecRegSep_s
            ps_s_i = PolyShape([ps_s.Vertices[i]], 1)
            ps_r = polyUnion(ps_r, ps_s_i)
        end

        for j in vecRegSep_c
            ps_c_j = PolyShape([ps_c.Vertices[j]], 1)
            ps_r = polyUnion(ps_r, ps_c_j)
        end
    end
    
    return ps_r

end


function polyDifference(ps_s, ps_c)
    V_s = ps_s.Vertices[1]
    numVertices_s = size(V_s, 1)

    V_c = ps_c.Vertices[1]
    numVertices_c = size(V_c, 1)

    poly_s = Devices.Polygon([Devices.Point(V_s[i,1], V_s[i,2]) for i = 1:numVertices_s])
    poly_c = Devices.Polygon([Devices.Point(V_c[i,1], V_c[i,2]) for i = 1:numVertices_c])
    poly_ = Devices.Polygons.clip(Clipper.ClipTypeDifference, poly_s, poly_c)

    numRegiones = length(poly_)
    ps_out = PolyShape([], numRegiones)
    for k = 1:numRegiones
        poly_k = poly_[k].p
        numVertices_k = size(poly_k, 1)
        V_k = zeros(numVertices_k, 2)
        for i = 1:numVertices_k
            V_k[i,1] = poly_k[i][1]
            V_k[i,2] = poly_k[i][2]
        end
        ps_out.Vertices = push!(ps_out.Vertices, V_k)
    end
    ps_out.NumRegions = length(ps_out.Vertices)
    return ps_out
end



function polyDifference_v2(ps_s, ps_c)
    # ps_c debe tener sólo una región.

    numRegions_s = ps_s.NumRegions
    numRegions_c = ps_c.NumRegions

    ps_out = PolyShape([], 0)
    for i = 1:numRegions_s

        ps_ic = polyShape.polyDifference(PolyShape([ps_s.Vertices[i]], 1), ps_c)
        
        for k = 1:length(ps_ic.Vertices)
            ps_out.Vertices = push!(ps_out.Vertices, ps_ic.Vertices[k])
        end
    end
    ps_out.NumRegions = length(ps_out.Vertices)

    return ps_out
end


function polyDifference_v3(ps_s, ps_c)

    ps_s_ = PolyShape([], 0)
    ps_s_.Vertices = copy(ps_s.Vertices)
    ps_s_.NumRegions = length(ps_s_.Vertices)
    
    numRegions_c = ps_c.NumRegions

    ps_out = PolyShape([], 0)
    for i = 1:numRegions_c
        ps_c_i = PolyShape([ps_c.Vertices[i]], 1)
        ps_out_i = polyDifference_v2(ps_s_, ps_c_i)
        for k = 1:length(ps_out_i.Vertices)
            ps_out.Vertices = push!(ps_out.Vertices, ps_out_i.Vertices[k])
        end
        ps_s_.Vertices = ps_out.Vertices
        ps_s_.NumRegions = length(ps_s_.Vertices)
        ps_out = PolyShape([], 0)
    end

    return ps_s_
end


function polyIntersect(ps_s, ps_c)

    V_s = ps_s.Vertices[1]
    numVertices_s = size(V_s, 1)

    V_c = ps_c.Vertices[1]
    numVertices_c = size(V_c, 1)

    poly_s = Devices.Polygon([Devices.Point(V_s[i,1], V_s[i,2]) for i = 1:numVertices_s])
    poly_c = Devices.Polygon([Devices.Point(V_c[i,1], V_c[i,2]) for i = 1:numVertices_c])
    poly_ = Devices.Polygons.clip(Clipper.ClipTypeIntersection, poly_s, poly_c)

    numRegiones = length(poly_)
    ps_out = PolyShape([], numRegiones)
    for k = 1:numRegiones
        poly_k = poly_[k].p
        numVertices_k = size(poly_k, 1)
        V_k = zeros(numVertices_k, 2)
        for i = 1:numVertices_k
            V_k[i,1] = poly_k[i][1]
            V_k[i,2] = poly_k[i][2]
        end
        ps_out.Vertices = push!(ps_out.Vertices, V_k)
    end
    ps_out.NumRegions = length(ps_out.Vertices)
    return ps_out
 
end


function polyIntersect_v2(ps_s, ps_c)
    # ps_c debe tener sólo una región.

    numRegions_s = ps_s.NumRegions
    numRegions_c = ps_c.NumRegions

    ps_out = PolyShape([], 0)
    for i = 1:numRegions_s

        ps_ic = polyShape.polyIntersect(PolyShape([ps_s.Vertices[i]], 1), ps_c)
        
        for k = 1:length(ps_ic.Vertices)
            ps_out.Vertices = push!(ps_out.Vertices, ps_ic.Vertices[k])
        end
    end
    ps_out.NumRegions = length(ps_out.Vertices)

    return ps_out
end


function polyIntersect_v3(ps_s, ps_c)

    ps_s_ = PolyShape([], 0)
    ps_s_.Vertices = copy(ps_s.Vertices)
    ps_s_.NumRegions = length(ps_s_.Vertices)
    
    numRegions_c = ps_c.NumRegions

    ps_out = PolyShape([], 0)
    for i = 1:numRegions_c
        ps_c_i = PolyShape([ps_c.Vertices[i]], 1)
        ps_out_i = polyIntersect_v2(ps_s_, ps_c_i)
        for k = 1:length(ps_out_i.Vertices)
            ps_out.Vertices = push!(ps_out.Vertices, ps_out_i.Vertices[k])
        end
        ps_s_.Vertices = ps_out.Vertices
        ps_s_.NumRegions = length(ps_s_.Vertices)
        ps_out = PolyShape([], 0)
    end

    return ps_s_
end



function polyExpand(ps, dist)
    V = ps.Vertices[1]
    numVertices = size(V, 1)

    poly = Devices.Polygon([Devices.Point(V[i,1], V[i,2]) for i = 1:numVertices])
    poly_ = offset(poly, dist)

    numRegiones = length(poly_)
    ps_out = PolyShape([], numRegiones)
    for k = 1:numRegiones
        poly_k = poly_[k].p
        numVertices_k = size(poly_k, 1)
        V_k = zeros(numVertices_k, 2)
        
        for i = 1:numVertices_k
            V_k[i,1] = poly_k[i][1]
            V_k[i,2] = poly_k[i][2]
        end
        
        V_k = [V_k[2:end,:]; V_k[1,:]']
        ps_out.Vertices = push!(ps_out.Vertices, V_k)
    end

    return ps_out
end
    

function polyExpandSides(ps, dist, edges)
    
    V = copy(ps.Vertices[1])
    V_d = poly2D.expandPolygonSides(V, dist, edges)
    ps_out = PolyShape([V_d], 1)
    return ps_out
end


function polyExpandSides_v2(ps, vecDist, vecLados)

    numLados = size(ps.Vertices[1],1)
    
    # Genera superficie bruta
    vecAnchos = zeros(numLados,1)
    for i=1:numLados
        for j=1:length(vecDist)
            if i == vecLados[j]
                vecAnchos[i] = vecDist[j]
            end        
        end
    end

    vecDeltaAnchos = copy(vecAnchos)
    vecSignos = sign.(vecDeltaAnchos)
    delta1 = .01/2
    numIteraciones1 = maximum(abs.(vecDeltaAnchos)) / delta1
    ps_ = PolyShape([ps.Vertices[1]],1)
    for i=1:numIteraciones1
        for j=1:numLados
            if vecSignos[j]*vecDeltaAnchos[j] >= delta1
                ps_ = polyShape.polyExpandSides(ps_, delta1*vecSignos[j], j)
                vecDeltaAnchos[j] -= delta1*vecSignos[j]
            end
        end
    end

    return ps_
end


export extraeInfoPoly, isPolyConvex, isPolyInPoly, plotPolyshape, plotPolyshape3d_v1, plotPolyshape3d_v2, plotPolyshape3d_v3,
        polyArea_v2, polyDifference, polyDifference_v2, polyDifference_v3, polyShape2constraints, polyOrientation, polyUnion, polyUnion_v2, 
        polyIntersect, polyIntersect_v2, polyIntersect_v3, polyExpand, polyExpandSides, plotPolyshape3d_v4, plotPolyshape3d_v5,
        polyExpandSides_v2

end
