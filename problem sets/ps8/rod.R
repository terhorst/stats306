library(tidyverse)
library(ggplot2)

options(repr.plot.width=4, repr.plot.height=4)
run_rod_experiment <- function() {
    x <- runif(1)
    y <- runif(1)
    theta <- pi * runif(1)
    dx = .5 * cos(theta)
    dy = .5 * sin(theta)
    df = tibble(xend = x + dx, x = x - dx , yend = y + dy, y = y - dy)
    label <- "doesn't intersect"
    if (between(1, y - abs(dy), y + abs(dy)) | 
        between(0, y - abs(dy), y + abs(dy))) label <- "intersects"
    ggplot(df) + 
    geom_hline(yintercept = 0) + 
    geom_hline(yintercept = 1) + 
    geom_point(x=x, y=y) +
    geom_segment(aes(x=x, xend=xend, y=y, yend=yend), color="blue") +
    theme_bw() + annotate(geom="text", x=-.5, y=1.8, label=label) +
    coord_cartesian(ylim=c(-1, 2), xlim=c(-1, 2))
}
run_rod_experiment()