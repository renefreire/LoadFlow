% Fun��o para converter uma vari�vel representada em coordenadas polares
% para coordenadas retangulares

function retangular = conv_retang(modulo,angulo)
retangular = modulo.*cos(angulo) + 1j*modulo.*sin(angulo);