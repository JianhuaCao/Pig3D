### GOplot 1.0.2
#
# Jianhua Cao @ HZAU
# Last modified: 2016-12-7
# Ver0.1
library(GOplot) # also load ggplot2, RColorBrewer
# library(RColorBrewer)
# library(ggplot2)
setwd(".")

# data(EC) # demo data
# demo_circ <- circle_dat(EC$david, EC$genelist)
# demo_IDs <- c('GO:0007507', 'GO:0001568', 'GO:0001944')

inf_d = 'david.3d4.txt'
# Category	ID	Term	label	Genes	adj_pval
# BP	GO:0006955	immune response	yes	CCR7, ...
# TNFAIP3, THBS1, CCL5, IL15, FAS, CD40, ...
# ...
d <- read.table(inf_d, header = T, sep = "\t")

inf_g = 'genelist.3d4.csv'
# ID,logFC,AveExpr,t,P.Value,adj.P.Value,B,label
# RSAD2,11.06755529,9963.904363,37.13682319,7.15E-302,4.36E-299,30,yes
# CCL3L1,9.720784638,953.4611321,17.55567939,5.38E-69,4.81E-67,30,yes
# ...
g <- read.csv(inf_g)

circ <- circle_dat(d, g)
# category	ID	term	count	genes	logFC	adj_pval	zscore
# BP	GO:0006955	immune	response	46	CCR7	2.710841	3.55e-09	6.192562
# BP	GO:0006955	immune	response	46	FYB	4.964663	3.55e-09	6.192562
# ...


### GOBubble: bubble plot (cjh modified using ggplot2)
sub_d <- d[,c("Category", "ID", "label", "adj_pval")]
sub_circ <- unique(circ[,c("ID", "count", "zscore")])
df <- merge(sub_d, sub_circ, by = "ID")
# ID	Category	label	adj_pval	count	zscore
# GO:0000981	MF	no	0.9826889	15	1.8073922
# GO:0002230	BP	no	0.9575399	10	0.0000000
# ...
p <- ggplot(df, aes(x = zscore,
                    y = -log10(adj_pval),
                    colour = Category, size = count))
p +
  geom_point(alpha = .5) +
  scale_size_area(max_size = 10) +
  scale_colour_brewer(palette = "Set1") +
  geom_text(data = df[df$label=='yes',], aes(label = ID),
            size = 3, show.legend = FALSE) +
  geom_hline(aes(yintercept = 1.3),
             colour = "orange", linetype = "dashed", size = 1) +
  labs(x = "z-score", y = "-log10(padj)") +
  theme(
    panel.background = element_rect(fill="NA", colour = "black", size = .5, linetype = 1),
    panel.grid.major = element_line(colour = "grey", linetype = "dotted"),
    panel.grid.minor = element_line(colour = "grey", linetype = "dotted"),
    legend.position = "right",
    axis.text  = element_text(size = 20),
    axis.title = element_text(size = 20),
    strip.text = element_text(face = "bold", size = rel(1.2)),
    strip.background = element_rect(colour = "black", size = .5))


### GOCircle: Circular visualization of gene annotation enrichment
IDs <-  as.character(d[d$label=='yes',]$ID) # David IDs of Interest
GOCircle(circ, nsub = IDs, table.legend = FALSE,
         label.size = 4, rad1 = 1.4, rad2 = 2.4)


Process <- as.character(d[d$label=='yes',]$Term) # David Terms of interest
Genes <- g[c("ID", "logFC")]
chord <- chord_dat(circ, Genes, Process)
### GOChord: Display of the relationship between genes and terms
GOChord(chord,
        space = .01,
        border.size = 0,
        gene.order = 'logFC', gene.space = .2, gene.size = 3,
        lfc.min = -10, lfc.max = 10)

### GOHeat: Heatmap of genes and terms
GOHeat(chord[1:20,],
       nlfc = 1,
       fill.col = c('red', 'white', 'green'))

### GOCluster: Golden eye
GOCluster(circ, Process,
          clust.by = 'term',
          lfc.width = .5, lfc.space = .1, lfc.min = -10, lfc.max = 10,
          term.width = 2, term.space = .1)


### GOVenn: Venn diagram
t <- c('R-SSC-191273',
       'R-SSC-2467813',
       'R-SSC-2500257')
c1 <- subset(circ, term==t[1], c(genes, logFC))
c2 <- subset(circ, term==t[2], c(genes, logFC))
c3 <- subset(circ, term==t[3], c(genes, logFC))
GOVenn(c1, c2, c3, label = t)
