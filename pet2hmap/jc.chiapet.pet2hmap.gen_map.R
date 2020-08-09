#!/usr/bin/env Rscript
#
# Plot heatmap using heatmat.txt
#
# 2	1	1	1
# 1	3	1	1
# 1	1	2	1
# 1	1	1	2
#
# Jianhua Cao @ HZAU
# Last modified: 2016-9-2
# Ver0.2
options(echo = F)
args <- commandArgs(trailingOnly = T)

# library(gplots)
library("pheatmap")
library("RColorBrewer")
setwd(".") # directory where heatmat.txt located

if (length(args) < 1) {
  args <- c("--help")
}

if ("--help" %in% args) { # Help section
  cat("
      Usage:
      $0 <out:normIntensity>
      \n")
  q(save = "no")
}

# ---- color scheme
colors <- list(
  pal.YlOrRd  = brewer.pal(9, "YlOrRd")[1:9],
  pal.YlOrBr  = brewer.pal(9, "YlOrBr")[1:9],
  pal.Reds    = brewer.pal(9, "Reds")[1:9],
  pal.OrRd    = brewer.pal(9, "OrRd")[1:9],
  pal.Oranges = brewer.pal(9, "Oranges")[1:9],

  pal.YlGn   = brewer.pal(9, "YlGn")[1:9],
  pal.Greens = brewer.pal(9, "Greens")[1:9],
  pal.BuGn   = brewer.pal(9, "BuGn")[1:9],

  pal.Blues  = brewer.pal(9, "Blues")[1:9],

  cjh.col1 = c("floralwhite", "yellowgreen", "green", "forestgreen", "darkgreen"),
  cjh.col2 = c("floralwhite", "orange", "red", "firebrick", "firebrick4"),
  cjh.col3 = c("yellow", "red", "firebrick4"),
  cjh.col4 = c("steelblue", "yellow", "firebrick4"),
  cjh.col5 = c("steelblue", "yellow", "red", "firebrick4"),
  cjh.col6 = c("white", "orange", "red", "firebrick", "firebrick4"),
  cjh.col7 = c("white", "steelblue", "yellow", "red", "firebrick", "firebrick4"),
  cjh.col8 = c("white", "darkseagreen3", "darkseagreen", "forestgreen", "darkgreen"))

infile     = args[1] # heatmat.txt, tab-delimited
hmap.color = args[2] # color scheme
ouf_pdf = paste(sub('heatmat', 'heatmap', infile), '.pdf', sep="")
pdf(ouf_pdf, onefile = F) # prevent extra blank page

df <- read.table(infile, head = F)
hmap_data <- log2(as.matrix(df))
# range(mat)
# hist(mat)
px = max(hmap_data)
bk = unique(c(seq(0, 0.2*px, 40),
              seq(0.2*px, 0.4*px, length = 90),
              seq(0.4*px, 0.6*px, length = 90),
              seq(0.6*px, 0.8*px, length = 60),
              seq(0.8*px,   1*px, length = 50)))
hmap_color <- colorRampPalette(colors[[hmap.color]])(length(bk)-1)

# ---- heatmap
pheatmap(hmap_data, legend = F, cluster_row = F, cluster_col = F,
         show_rownames = F, show_colnames = F,
         color = hmap_color, breaks = bk,
         cellwidth = 1.5, cellheight = 1.5, border_color=NA,
         fontsize=5)

dev.off()

# sessionInfo()
