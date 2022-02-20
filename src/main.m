% ANSISPOT - Programa para An�lise de Sistemas de Pot�ncia
% 
% Autor: Rene Cruz Freire
% E-mail: b1.rene.cruz@gmail.com

clc;
clear;

path = pwd;

disp('------------------------------------------------------------------');
disp('****************************ANSISPOT******************************');
disp('------------------------------------------------------------------');
disp('Programa para An�lise de Sistemas de Pot�ncia em Regime Permanente');

%--------------------------------------------------------------------------
% Escolha do formato do arquivo do sistema de pot�ncia
%--------------------------------------------------------------------------
disp(' ');
disp('Abra o arquivo de rede na caixa de di�logo a seguir:');
pause(5);
nome_arquivo = uigetfile;
extensao = nome_arquivo(end-3:end);
switch extensao
    case '.pwf'
        % Formato CEPEL
        conversor = 'cepel2matlab';
    case '.cdf'
        % Formato IEEE
        conversor = 'ieee2matlab';
    otherwise
        % Mensagem de erro
        error('Escolha inv�lida. Tente novamente');
end

%--------------------------------------------------------------------------
% Inser��o do nome do arquivo de rede a ser convertido para o formato 
% padr�o do MATLAB (.m)
%--------------------------------------------------------------------------
% Caminho para o arquivo de rede
caminho_arquivo = [path,'/',nome_arquivo];

% Convers�o dos arquivos atrav�s de script perl
perl(conversor,caminho_arquivo);

% Carregando a rede el�trica rec�m-convertida
% extensao = '.m';
inicial = 'd_';
rede_eletrica = [inicial,nome_arquivo];
run(rede_eletrica);

%--------------------------------------------------------------------------
% Par�metros da rede e c�lculo de Ybarra
%--------------------------------------------------------------------------
[param] = parametro(rede);
[param] = ybarra(param,rede);

%--------------------------------------------------------------------------
% Tipo de estudo desejado
%--------------------------------------------------------------------------
disp(' ');
disp('M�todo para c�lculo do fluxo de pot�ncia:');
disp(' ');
disp('1 - Newton-Raphson Completo');
disp('2 - Newton-Raphson Desacoplado');
disp('3 - Newton-Raphson Desacoplado R�pido');
disp('4 - Linearizado');
disp(' ');
estudo = input('Estudo escolhido -> ');
if (estudo == 1 || estudo == 2 || estudo == 3)
    % Fluxo de Pot�ncia AC
    [flow, stat, param, inj] = fluxo(rede,param,nome_arquivo,estudo);
elseif (estudo == 4)
    % Fluxo de Pot�ncia DC
    [stat, flow, inj] = fluxoDC(rede,param);
else
    % Mensagem de erro
    error('Escolha inv�lida');
end
