% Função para cálculo das injeções de potência ativa e reativa

function [Pcal, Qcal] = potencia_calculada(stat,param)

% Declaração de variáveis
Vbarra = stat.Vbarra;
ang = stat.ang;
G = param.G;
B = param.B;

Pcal = zeros(param.nBarras,1);
Qcal = zeros(param.nBarras,1);

for i = 1:param.nBarras
    for j = 1:param.nBarras
        Pcal(i) = Pcal(i) + Vbarra(i)*Vbarra(j)*(G(i,j)*cos(ang(i)-ang(j)) + B(i,j)*sin(ang(i)-ang(j)));
        Qcal(i) = Qcal(i) + Vbarra(i)*Vbarra(j)*(G(i,j)*sin(ang(i)-ang(j)) - B(i,j)*cos(ang(i)-ang(j)));
    end
end