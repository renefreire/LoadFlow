% ANSISPOT - Programa para Análise de Sistemas de Potência
% 
% Autor: Rene Cruz Freire
% E-mail: b1.rene.cruz@gmail.com

clc;
clear;

cd ..;
currentFolder = pwd;

disp('------------------------------------------------------------------');
disp('****************************ANSISPOT******************************');
disp('------------------------------------------------------------------');
disp('Programa para Análise de Sistemas de Potência em Regime Permanente');

%--------------------------------------------------------------------------
% Escolha do formato do arquivo do sistema de potência
%--------------------------------------------------------------------------
disp(' ');
disp('Informe o formato do arquivo de rede:');
disp(' ');
disp('1 - CEPEL(.pwf)');
disp('2 - IEEE(.cdf)');
disp(' ');
formato = input('Formato escolhido -> ');
switch formato
    case 1
        % Formato CEPEL
        conversor = 'cepel2matlab';
        extensao = '.pwf';
    case 2
        % Formato IEEE
        conversor = 'ieee2matlab';
        extensao = '.cdf';
    otherwise
        % Mensagem de erro
        error('Escolha inválida. Tente novamente');
end

%--------------------------------------------------------------------------
% Inserção do nome do arquivo de rede a ser convertido para o formato 
% padrão do MATLAB (.m)
%--------------------------------------------------------------------------
disp(' ');
nome_arquivo = input('Nome do arquivo (sem extensão): ','s');
setenv('PATH','~\LoadFlow');
caminho_arquivo = [getenv('PATH'),'\casosCEPEL\',nome_arquivo,'.pwf'];

% Conversão dos arquivos através de script perl
perl(conversor,caminho_arquivo);

% Carregando a rede elétrica recém-convertida
% extensao = '.m';
inicial = 'd_';
rede_eletrica = [inicial,nome_arquivo];
run(rede_eletrica);

%--------------------------------------------------------------------------
% Parâmetros da rede e cálculo de Ybarra
%--------------------------------------------------------------------------
[param] = parametro(rede);
[param] = ybarra(param,rede);

%--------------------------------------------------------------------------
% Tipo de estudo desejado
%--------------------------------------------------------------------------
disp(' ');
disp('Método para cálculo do fluxo de potência:');
disp(' ');
disp('1 - Newton-Raphson Completo');
disp('2 - Newton-Raphson Desacoplado');
disp('3 - Newton-Raphson Desacoplado Rápido');
disp('4 - Linearizado');
disp(' ');
estudo = input('Estudo escolhido -> ');
if (estudo == 1 || estudo == 2 || estudo == 3)
    % Fluxo de Potência AC
    [flow, stat, param, inj] = fluxo(rede,param,nome_arquivo,estudo);
elseif (estudo == 4)
    % Fluxo de Potência DC
    [stat, flow, inj] = fluxoDC(rede,param);
else
    % Mensagem de erro
    error('Escolha inválida');
end
