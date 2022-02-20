% Função para formação das matrizes Ybarra e Zbarra

function [param] = ybarra(param,rede)

% Tipos de barra
% 1 - PQ
% 2 - PV
% 3 - Swing
[inj.tipo] = tipo_barra(rede,param);

%**************************************************************************
% Fluxo de Potência Completo
%**************************************************************************
r = rede.Linhas(:,9); % Resistência da linha de transmissão
x = rede.Linhas(:,10); % Reatância da linha de transmissão
param.z = r + 1j*x; % Vetor de impedâncias do sistema de potência
param.y = 1./param.z; % Vetor de admitâncias primitiva em cada ramo
param.bsh = 0 + 1j*rede.Linhas(:,11); % Susceptância em shunt com a linha de transmissão
[param] = tap(rede,param); % Tap do transformador
param.a = abs(param.t); % Posição de tap
param.phi = angle(param.t); % Ângulo defasador
[param] = shunt(rede,param); % Equipamentos em shunt na barra
param.Y = zeros(param.nBarras,param.nBarras); % Inicialização da matriz de admitância nodal

% Formação dos elementos fora da diagonal principal
for l = 1:param.nLinhas
    d = param.DE(l);
    p = param.PARA(l);
    if param.t(l) == 0
        param.Y(d,p) = param.Y(d,p) - param.y(l);
        param.Y(p,d) = param.Y(p,d) - param.y(l);
    else
        param.Y(d,p) = param.Y(d,p) - param.y(l)/conj(param.t(l));
        param.Y(p,d) = param.Y(p,d) - param.y(l)/param.t(l);
    end
end

% Formação dos elementos da diagonal principal
for b = 1:param.nBarras
    for l = 1:param.nLinhas
        d = param.DE(l);
        p = param.PARA(l);
        if d == b
            if param.t(l) == 0
                param.Y(b,b) = param.Y(b,b) + param.y(l) + param.bsh(l)/2;
            else
                param.Y(b,b) = param.Y(b,b) + param.y(l)/(param.a(l)^2);
            end
        elseif p == b            
            param.Y(b,b) = param.Y(b,b) + param.y(l) + param.bsh(l)/2;
        end
    end
    param.Y(b,b) = param.Y(b,b) + param.yshunt(b);
end

param.Z = inv(param.Y); % Matriz de impedância nodal
param.Z = sparse(param.Z);

% Armazenamento das matrizes de admitância e impedância nodal aproveitando
% as características de esparsidade
param.Y = sparse(param.Y);

param.G = real(param.Y); % Matriz de condutância nodal
param.B = imag(param.Y); % Matriz de susceptância nodal
param.g = real(param.y); % Vetor de condutâncias primitivas
param.b = imag(param.y); % Vetor de susceptâncias primitivas

%**************************************************************************
% Fluxo de Potência Linearizado
%**************************************************************************
B = zeros(param.nBarras,param.nBarras); % Matriz do tipo admintância nodal

% Formação dos elementos fora da diagonal principal
for l = 1:param.nLinhas
    d = param.DE(l);
    p = param.PARA(l);
    B(d,p) = B(d,p) - 1/x(l);
    B(p,d) = B(p,d) - 1/x(l);
end

% Formação dos elementos da diagonal principal
for b = 1:param.nBarras
    for l = 1:param.nLinhas
        d = param.DE(l);
        p = param.PARA(l);
        if (d == b)||(p == b)
            B(b,b) = B(b,b) + (1/x(l));
        end
    end
end

% Eliminação das equações referentes à barra swing
sw = find(inj.tipo == 3);
B(sw,:) = [];
B(:,sw) = [];

% Inversão da matriz
param.Binv = inv(B);
