library(ggplot2)
ggplot(a2i.pp, aes(x=year)) + geom_line(aes(y=a2.income)) +
        geom_line(aes(y=para.pop * 1.104e-02-2.333e+04), color="red") +
        ylab("A2 Income") +
        scale_y_continuous(sec.axis = sec_axis(~./1.1e-2+2.333e+04, 
                                               name = "Paraguay Population")) +
        theme_minimal()

