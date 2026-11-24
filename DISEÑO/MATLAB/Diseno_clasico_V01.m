%% Datos

% Eléctricos
Vn = 350; %V
Imax = 103; %A
J = 12; %A/mm2
p = 5; %polos
fn = 1000; %Hz


% Físicos
Nn = 12000; %rpm
Sigma_tan = 24500; %Pa


% Magnéticos
Uo = 4*pi*10^(-7); %H/m
B_delta = 0.8; %Tesla
B_sat = 1.9; %Tesla
B_cd = 1.46; %Tesla

% Dimensiones
Dext = 85; %mm
Lu = 90; %mm
delta = 0.9; %mm
Ns = 12; %ranuras/dientes
w_sz = 2; %mm (separación entre zapatas)
t_lam = 0.3; %mm
alpha_chaflan = 30; %deg


% Constantes
ksat = 1.225;
Kst = 0.95;
kfill = 0.55;
%% Ecuaciones Corregidas

syms Dei;

% Paso linear de ranura y diente (en mm)
tau_d = (pi*Dei)/Ns;

% Flujo magnético máximo (Unidades T*mm2, el factor 10^-6 se cancelará luego)
Phi_d_max = B_delta * tau_d * Lu * ksat;

% Ancho del cuerpo del diente (en mm)
w_cd = Phi_d_max/(Kst * Lu * B_cd);

% Carga lineal (en Amperios / Metro)
A_carga_Am = Sigma_tan/B_delta;

% Carga lineal (en Amperios / Milímetro) -> ¡EL ARREGLO ESTÁ AQUÍ!
A_carga_Amm = A_carga_Am / 1000;

% Area útil
A_u = (A_carga_Amm*tau_d)/(kfill*J);

% Altura del diente (usamos A/mm para que cruce bien con J en A/mm2)
hd = (A_carga_Amm*tau_d)/(kfill*J*(tau_d-w_cd));

% Profundidad de zapata 
% (Usamos A_carga_Am en A/m porque Uo está en H/m y las unidades cuadran a mm)
hz = (Uo*A_carga_Am*tau_d)/(2*(B_sat-B_delta)) * (w_sz/delta);

% Altura zapata
Deltax = ((tau_d-w_sz)-w_cd)/2;
dchaflan = Deltax*tand(alpha_chaflan);

% Altura Yugo
Phi_p = 1.2* Phi_d_max;
hy = Phi_p/(2*Kst*Lu*B_cd);

% Diámetro interior
eq = Dext == Dei + 2*(hd + hz + dchaflan + hy);

% Resolver y mostrar
Dei_solucion = vpasolve(eq, Dei);

% 1. Evaluar las variables simbólicas y convertirlas a números decimales
Dei_val = double(Dei_solucion);
tau_val = double(subs(tau_d, Dei, Dei_val));
wcd_val = double(subs(w_cd, Dei, Dei_val));
Au_val  = double(subs(A_u, Dei, Dei_val));
hd_val  = double(subs(hd, Dei, Dei_val));
hz_val  = double(subs(hz, Dei, Dei_val));
dchaflan_val = double(subs(dchaflan, Dei, Dei_val));
hy_val  = double(subs(hy, Dei, Dei_val));

% 2. Definir las columnas: Nombres enteros, Valores y Unidades
Variable = {'Paso de ranura y diente (tau)'; ...
            'Ancho cuerpo del diente (wcd)'; ...
            'Área útil (Au)'; ...
            'Altura del diente (hd)'; ...
            'Profundidad de zapata (hz)'; ...
            'Altura del chaflán (dchaflan)'; ...
            'Altura del yugo (hy)'; ...
            'Diámetro Interno (Dei)'};
            
Valor = [tau_val; wcd_val; Au_val; hd_val; hz_val; dchaflan_val; hy_val; Dei_val];

Unidad = {'mm'; 'mm'; 'mm2'; 'mm'; 'mm'; 'mm'; 'mm'; 'mm'};

% 3. Crear la tabla de MATLAB
Tabla_Resultados = table(Variable, Valor, Unidad);

% 4. Exportar la tabla a un archivo CSV
writetable(Tabla_Resultados, 'resultados_motor.csv');

% Mensaje de confirmación
disp('¡Archivo resultados_motor.csv exportado correctamente!');