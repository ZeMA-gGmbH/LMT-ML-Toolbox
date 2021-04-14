# mltoolbox_matlab

## Start
addPaths;
load naph.mat
fulltoolbox = Factory.FullToolboxMultisens();
fulltoolbox.train(sensors,profile);         % Profile = Naphtalene concentration
prediction = fulltoolbox.apply(sensors);