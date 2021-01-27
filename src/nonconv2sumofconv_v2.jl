function nonconv2sumofconv_v2(ps)

    V = copy(ps.Vertices[1])
    setPuntos = 1:size(V,1)
    flagConvex = polyShape.isPolyConvex(ps)[1]

    matPuntosConvHull = poly2D.verticesConvHull(V)
    setPuntosConvHull = sort(unique(matPuntosConvHull))
    setPuntosNoConvexos = setdiff(setPuntos,setPuntosConvHull)

    set_r = setPuntos
    cond = true
    ps_sub = PolyShape([],0)
    ps_r = PolyShape([],0)
    contador = 0
    V_r = copy(V)
    while cond
        if length(setPuntosNoConvexos) >= 1
            contador = contador + 1
            pnc = maximum(setPuntosNoConvexos)
            set_r = setdiff(set_r, pnc)
            set_np = copy(pnc)
            largo_r = length(set_r)
            for i = 1:largo_r
                if pnc > maximum(set_r)
                    p_adic = minimum(set_r)
                else
                    p_adic = minimum(set_r[set_r.>pnc])
                end                 
                set_np = union(set_np, p_adic)
                if length(set_np) >=3
                    V_np = copy(V_r[set_np,:])
                    flagConvex_np = poly2D.checkConvex(V_np)
                    flagInscrito_np = polyShape.isPolyInPoly(PolyShape([V_np],1), ps)
                    flagFactible = (flagConvex_np && flagInscrito_np) 
                    if !flagFactible
                        set_np = setdiff(set_np, p_adic)
                    end
                end
                set_r = setdiff(set_r,p_adic)
            end

            ps_sub.Vertices = push!(ps_sub.Vertices, V_r[set_np,:])
            ps_sub.NumRegions = length(ps_sub.Vertices)

            ps_r = polyShape.polyDifference_v3(ps, ps_sub)
            V_r = copy(ps_r.Vertices[1])
            set_r = 1:size(V_r,1)
            matPuntosConvHull = poly2D.verticesConvHull(V_r)
            setPuntosConvHull = sort(unique(matPuntosConvHull))
            setPuntosNoConvexos = setdiff(set_r,setPuntosConvHull)
            
        else
            cond = false
            ps_sub.Vertices = push!(ps_sub.Vertices, V_r[set_r,:])
            ps_sub.NumRegions = length(ps_sub.Vertices)
        end

    end

    SP  = Array{SubPoly,1};
    for i = 1:ps_sub.NumRegions
        V_i = ps_sub.Vertices[i]
        set_j = []
        for j = 1:size(V_i,1)
            p_j = V_i[j,:]
            for k = 1:size(V,1)
                p_k = V[k,:]
                dist_jk = sqrt(sum((p_j .- p_k).^2))
                if dist_jk < .1
                    set_j = union(set_j,k)             
                end
            end
        end
        if i==1 
            SP = Array{SubPoly,1}([SubPoly(set_j,[])]);
        else
            push!(SP, SubPoly(set_j,[]));
        end    
    end

    for i=1:ps_sub.NumRegions
        vecLadoComun=zeros(ps_sub.NumRegions,1);
        for j=1:ps_sub.NumRegions
            if i != j
                si = SP[i].points;
                sj = SP[j].points;
                aux=ismembern(si, sj);
                lc=[];
                if sum(aux)==2
                    vecPos=1:length(aux);
                    vecPos_=vecPos[aux];
                    if aux[1]==1 && aux[end]==1
                        lc=[vecPos_[end] vecPos_[1]];
                    else
                        lc=vecPos_;
                    end
                    vecLadoComun[j]=lc[1];
                end
            end
        end
        setfield!(SP[i], :ladoComun, vecLadoComun);
    end

    return ps_sub, SP
    
end
    