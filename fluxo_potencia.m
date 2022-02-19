% Fun��o para c�lculo das inje��es de pot�ncia nas barras e flow de
% pot�ncia nas linhas

function [flow, inj] = fluxo_potencia(param,stat,inj)

% Tens�o em coordenadas retangulares
Vret = conv_retang(stat.Vbarra,stat.ang);

% Pot�ncia injetada/consumida pelos equipamentos shunt
inj.Pshunt = zeros(param.nBarras,1);
inj.Qshunt = zeros(param.nBarras,1);
for k = 1:param.nBarras
    inj.Pshunt(k) = (stat.Vbarra(k)^2)*real(param.shunt(k));
    inj.Qshunt(k) = - (stat.Vbarra(k)^2)*imag(param.shunt(k));
end

% Fluxo de corrente nas linhas
flow.Iij = zeros(param.nBarras,param.nBarras);
for m = 1:param.nLinhas
    i = param.DE(m);
    j = param.PARA(m);
    if param.t(m) ~= 0
        flow.Iij(i,j) = param.y(m)*((Vret(i)/param.t(m)) - Vret(j))/param.t(m);
        flow.Iij(j,i) = param.y(m)*(Vret(j) - (Vret(i)/param.t(m)));
    else
        flow.Iij(i,j) = param.y(m)*(Vret(i) - Vret(j)) + Vret(i)*(param.bsh(m)/2);
        flow.Iij(j,i) = param.y(m)*(Vret(j) - Vret(i)) + Vret(j)*(param.bsh(m)/2);
    end
end
flow.Iij = sparse(flow.Iij);

% Fluxo de pot�ncia nas linhas
flow.Sij = zeros(param.nBarras,param.nBarras);
for m = 1:param.nLinhas
    i = param.DE(m);
    j = param.PARA(m);
    flow.Sij(i,j) = Vret(i)*conj(flow.Iij(i,j));
    flow.Sij(j,i) = Vret(j)*conj(flow.Iij(j,i));
end
flow.Sij = sparse(flow.Sij);
flow.Pij = full(real(flow.Sij));
flow.Qij = full(imag(flow.Sij));

% Perdas nas linhas de transmiss�o
flow.Lij = zeros(param.nLinhas,1);
for m = 1:param.nLinhas
    i = param.DE(m);
    j = param.PARA(m);
    flow.Lij(m) = flow.Sij(i,j) + flow.Sij(j,i);
end
flow.Lpij = real(flow.Lij);
flow.Lqij = imag(flow.Lij);

% Inje��o de pot�ncia nas barras de carga e gera��o
flow.Si = zeros(param.nBarras,1);
for i = 1:param.nBarras
    for j = 1:param.nBarras
        flow.Si(i) = flow.Si(i) + conj(Vret(i))* Vret(j)*param.Y(i,j);
    end
end

% Pot�ncia l�quida (gerada e consumida)
flow.Pi = real(flow.Si) - inj.Pshunt;
flow.Qi = -imag(flow.Si) - inj.Qshunt;
inj.Pload = inj.Pload + inj.Pshunt;
inj.Qload = inj.Qload + inj.Qshunt;
inj.Pger = flow.Pi + inj.Pload;
inj.Qger = flow.Qi + inj.Qload;

    