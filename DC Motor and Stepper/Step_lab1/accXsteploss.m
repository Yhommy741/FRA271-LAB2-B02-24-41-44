load("trapezoid_Vmax1000.mat")

w = squeeze(data.Data);
t = squeeze(data.Time);

plot(t,w)