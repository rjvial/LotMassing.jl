function infoPredio(x_predio, y_predio)


x_min = minimum(x_predio);
y_min = minimum(y_predio);
x_predio = x_predio-x_min*ones(size(x_predio));
y_predio = y_predio-y_min*ones(size(y_predio));
V_predio = [x_predio y_predio];

theta, cr = calculaAnguloRotacion(x_predio, y_predio);
numLados=length(theta);

R  = Array{RotInfo,1}([RotInfo(poly2D.rotationMatrix(theta[1]),cr[1,:],theta[1])]);
for i=2:numLados
    push!(R, RotInfo(poly2D.rotationMatrix(theta[i]),cr[i,:],theta[i]));
end

V_predio, R

end
