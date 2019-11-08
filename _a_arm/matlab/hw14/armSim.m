armParamHW14;  % load parameters

% instantiate arm, controller, and reference input classes 
alpha = 0.2;
addpath('../hw3'); arm = armDynamics(alpha, P);  
controller = armController(P);  
addpath('../hw2'); reference = signalGenerator(30*pi/180, 0.05);  
addpath('../hw2'); disturbance = signalGenerator(0.25, 0.0);
addpath('../hw2'); noise = signalGenerator(0.01);

% instantiate the data plots and animation
addpath('../hw2'); dataPlot = dataPlotter(P);
addpath('../hw2'); animation = armAnimation(P);
addpath('../hw13'); dataPlotObserver = dataPlotterObserver(P);

% main simulation loop
t = P.t_start;  % time starts at t_start
y = arm.h();
while t < P.t_end  
    % Propagate dynamics in between plot samples
    t_next_plot = t + P.t_plot;
    while t < t_next_plot % updates control and dynamics at faster simulation rate
        r = reference.square(t);
        d = disturbance.step(t);
        n = noise.random(t);  % noise
        [u, xhat, dhat] = controller.update(r, y+n);  
        y = arm.update(u+d);  % Propagate the dynamics
        t = t + P.Ts; % advance time by Ts
    end
    % update animation and data plots
    animation.update(arm.state);
    dataPlot.update(t, r, arm.state, u);
    dataPlotObserver.update(t, arm.state, xhat, d, dhat);
end

