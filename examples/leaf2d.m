%% Set up the mesh and the medium

% Create a rectangular mesh
xsize =  100;    % width of the region [mm]
ysize =  10;    % height of the region [mm]
dh = 0.2;       % discretisation size [mm]
x_half = xsize / 2;
y_half = ysize / 2;
vmcmesh = createRectangularMesh(xsize, ysize, dh);

% Set constant background coefficients

vmcmedium = createMedium(vmcmesh);
vmcmedium.absorption_coefficient = 0.003;     % absorption coefficient [1/mm]
vmcmedium.scattering_coefficient = 0.001;      % scattering coefficient [1/mm]
vmcmedium.scattering_anisotropy = 0.0;       % scattering anisotropy parameter [unitless] 
vmcmedium.refractive_index = 1.0003;            % refractive index [unitless]

leaf_width = 50.0;
leaf_height = 0.8;
rectangle_position=[0 0];
leaf_elements= findElements(vmcmesh, 'rectangle', rectangle_position, leaf_width, leaf_height);
% Set the optical coefficients inside the leaf
% vmcmedium.absorption_coefficient(leaf_elements) = 0.003; % absorption
vmcmedium.scattering_coefficient(leaf_elements) = 0.001;   % scattering
% vmcmedium.scattering_anisotropy(leaf_elements) = 0.0;   % g
% vmcmedium.refractive_index(leaf_elements) = 1.0003;           % index of refraction

%% Set up the boundary and create light sources
%
% createBoundary returns a structure which can be used to set the
% properties of each boundary element individually
vmcboundary = createBoundary(vmcmesh);

%% Light

% Select top of the simulation domain to be diffuse light source
line1_start = [0, y_half+1];
line1_end = [0,y_half];

% rectangle_diameter = sqrt(rectangle_width^2+rectangle_height^2);
line_width=xsize-0.5;

diffuse_light_elements = findBoundaries(vmcmesh, 'direction', ...
                              line1_start, ...
                              line1_end,  ...
                              line_width);
                          
% 4: Isotropic light source
%
% Photons are launched to all inward directions with an equal probability.

vmcboundary.lightsource(diffuse_light_elements) = {'isotropic'};

%% Run the Monte Carlo simulation
solution = ValoMC(vmcmesh, vmcmedium, vmcboundary);

%% Plot the solution
hold on;
plot3d = true;

patch('Faces',vmcmesh.H,'Vertices',vmcmesh.r,'FaceVertexCData', solution.element_fluence, 'FaceColor', 'flat','EdgeColor','none');
xlabel('[mm]');
ylabel('[mm]');
c = colorbar;                   
c.Label.String = 'Fluence [J/mm^2]';

if plot3d
    % The boundary solution is given as a constant fluence and extitance values
    % at each boundary element.

    % To plot the boundary fluence with plot3, an average coordinate of each
    % boundary element is calculated

    avgr = (vmcmesh.r(vmcmesh.BH(:, 1),:) + vmcmesh.r(vmcmesh.BH(:, 2),:))/2;
    h = plot3(avgr(:,1), avgr(:,2), (solution.boundary_exitance), 'b','LineWidth',1.5);
    legend(h,{'Boundary exitance'});

    % tilt the view
    az = -54;
    el = 34;
    view([az, el]);
    zlabel('Boundary value [(J/mm^2)]');
end

hold off

