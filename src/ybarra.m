% Fun��o para forma��o das matrizes Ybarra e Zbarra

function [param] = ybarra(param,rede)

% Tipos de barra
% 1 - PQ
% 2 - PV
% 3 - Swing
[inj.tipo] = tipo_barra(rede,param);

%**************************************************************************
% Fluxo de Pot�ncia Completo
%**************************************************************************
r = rede.Linhas(:,9); % Resist�ncia da linha de transmiss�o
x = rede.Linhas(:,10); % Reat�ncia da linha de transmiss�o
param.z = r + 1j*x; % Vetor de imped�ncias do sistema de pot�ncia
param.y = 1./param.z; % Vetor de admit�ncias primitiva em cada ramo
param.bsh = 0 + 1j*rede.Linhas(:,11); % Suscept�ncia em shunt com a linha de transmiss�o
[param] = tap(rede,param); % Tap do transformador
param.a = abs(param.t); % Posi��o de tap
param.phi = angle(param.t); % �ngulo defasador
[param] = shunt(rede,param); % Equipamentos em shunt na barra
param.Y = zeros(param.nBarras,param.nBarras); % Inicializa��o da matriz de admit�ncia nodal

% Forma��o dos elementos fora da diagonal principal
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

% Forma��o dos elementos da diagonal principal
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

param.Z = inv(param.Y); % Matriz de imped�ncia nodal
param.Z = sparse(param.Z);

% Armazenamento das matrizes de admit�ncia e imped�ncia nodal aproveitando
% as caracter�sticas de esparsidade
param.Y = sparse(param.Y);

param.G = real(param.Y); % Matriz de condut�ncia nodal
param.B = imag(param.Y); % Matriz de suscept�ncia nodal
param.g = real(param.y); % Vetor de condut�ncias primitivas
param.b = imag(param.y); % Vetor de suscept�ncias primitivas

%**************************************************************************
% Fluxo de Pot�ncia Linearizado
%**************************************************************************
B = zeros(param.nBarras,param.nBarras); % Matriz do tipo admint�ncia nodal

% Forma��o dos elementos fora da diagonal principal
for l = 1:param.nLinhas
    d = param.DE(l);
    p = param.PARA(l);
    B(d,p) = B(d,p) - 1/x(l);
    B(p,d) = B(p,d) - 1/x(l);
end

% Forma��o dos elementos da diagonal principal
for b = 1:param.nBarras
    for l = 1:param.nLinhas
        d = param.DE(l);
        p = param.PARA(l);
        if (d == b)||(p == b)
            B(b,b) = B(b,b) + (1/x(l));
        end
    end
end

% Elimina��o das equa��es referentes � barra swing
sw = find(inj.tipo == 3);
B(sw,:) = [];
B(:,sw) = [];

% Invers�o da matriz
param.Binv = inv(B);
