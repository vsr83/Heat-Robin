figure(1)
clf
subplot(2, 2, 1);
drawsolution(TT(:, 10), M, freenodes);
title('$t=10$s', 'FontSize', 14, 'Interpreter', 'latex')
xlim([0 0.0725]);
ylim(xlim);
axis off
set(gca, 'Position', [0 0.5125 0.45 0.45]);
axis off

subplot(2, 2, 2);
drawsolution(TT(:, 100), M, freenodes);
title('$t=100$s', 'FontSize', 14, 'Interpreter', 'latex')
xlim([0 0.0725]);
ylim(xlim);
set(gca, 'Position', [0.48 0.5125 0.45 0.45]);
axis off

subplot(2, 2, 3);
drawsolution(TT(:, 1000), M, freenodes);
title('$t=1000$s', 'FontSize', 14, 'Interpreter', 'latex')
xlim([0 0.0725]);
ylim(xlim);
set(gca, 'Position', [0 0.025 0.45 0.45]);
axis off

subplot(2, 2, 4);
drawsolution(TT(:, 10000), M, freenodes);
title('$t=10000$s', 'FontSize', 14, 'Interpreter', 'latex')
xlim([0 0.0725]);
ylim(xlim);
set(gca, 'Position', [0.48 0.025 0.45 0.45]);
axis off

figure(2)
clf
hold on
Tref0 = 36.806;
plot(dt*[0 num_timesteps], [Tref0, Tref0], 'k');
%plot(dt*(1:num_timesteps), Tmin(:, 2), 'b--', 'LineWidth', 2);
plot(dt*(1:num_timesteps), Tavg(:, 2), 'b', 'LineWidth', 2);
%plot(dt*(1:num_timesteps), Tmax(:, 2), 'r--', 'LineWidth', 1);
xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Temperature (s)', 'Interpreter', 'latex', 'FontSize', 16);
set(gca, 'FontSize', 14);
h = legend('Steady-state', 'Transient');
set(h, 'FontSize', 14);
set(h, 'Interpreter', 'latex');
grid on
set(gca, 'Box', 'on');

