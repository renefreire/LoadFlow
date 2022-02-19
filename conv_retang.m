% Função para converter uma variável representada em coordenadas polares
% para coordenadas retangulares

function retangular = conv_retang(modulo,angulo)
retangular = modulo.*cos(angulo) + 1j*modulo.*sin(angulo);