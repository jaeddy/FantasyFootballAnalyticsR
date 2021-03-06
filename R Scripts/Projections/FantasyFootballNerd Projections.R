###########################
# File: FantasyFootballNerd Projections.R
# Description: Downloads Fantasy Football Projections from FantasyFootballNerd.com
# Date: 3/3/2013
# Author: Isaac Petersen (isaac@fantasyfootballanalytics.net)
# Notes:
# To do:
###########################

#Load libraries
library("XML")
library("stringr")
library("ggplot2")
library("plyr")

#Functions
source(paste(getwd(),"/R Scripts/Functions/Functions.R", sep=""))
source(paste(getwd(),"/R Scripts/Functions/League Settings.R", sep=""))

#Download fantasy football projections from FantasyFootballNerd.com
qb_ffn <- readHTMLTable("http://www.fantasyfootballnerd.com/fantasy-football-projections", stringsAsFactors = FALSE)$projections
rb_ffn <- readHTMLTable("http://www.fantasyfootballnerd.com/fantasy-football-projections/RB", stringsAsFactors = FALSE)$projections
wr_ffn <- readHTMLTable("http://www.fantasyfootballnerd.com/fantasy-football-projections/WR", stringsAsFactors = FALSE)$projections
te_ffn <- readHTMLTable("http://www.fantasyfootballnerd.com/fantasy-football-projections/TE", stringsAsFactors = FALSE)$projections

#Add variable names for each object
names(qb_ffn) <- c("name_ffn","team_ffn","passComp_ffn","passAtt_ffn","passCompPct_ffn","passYds_ffn","passTds_ffn","passInt_ffn","rushYds_ffn","rushTds_ffn","pts_ffn")
names(rb_ffn) <- c("name_ffn","team_ffn","rushAtt_ffn","rushYds_ffn","rushYpc_ffn","rushTds_ffn","rec_ffn","recYds_ffn","recTds_ffn","fumbles_ffn","pts_ffn")
names(wr_ffn) <- c("name_ffn","team_ffn","rec_ffn","recYds_ffn","recTds_ffn","recYpc_ffn","rushAtt_ffn","rushYds_ffn","rushTds_ffn","fumbles_ffn","pts_ffn")
names(te_ffn) <- c("name_ffn","team_ffn","rec_ffn","recYds_ffn","recTds_ffn","recYpc_ffn","rushAtt_ffn","rushYds_ffn","rushTds_ffn","fumbles_ffn","pts_ffn")

#Add variable for player position
qb_ffn$pos <- as.factor("QB")
rb_ffn$pos <- as.factor("RB")
wr_ffn$pos <- as.factor("WR")
te_ffn$pos <- as.factor("TE")

#Merge players across positions
projections_ffn <- rbind.fill(qb_ffn, rb_ffn, wr_ffn, te_ffn)

#Add variables from other projection sources
projections_ffn$twoPts_ffn <- NA

#Remove special characters (percentage sign)
projections_ffn[,c("passComp_ffn","passAtt_ffn","passCompPct_ffn","passYds_ffn","passTds_ffn","passInt_ffn","rushAtt_ffn","rushYds_ffn","rushYpc_ffn","rushTds_ffn","rec_ffn","recYds_ffn","recTds_ffn","recYpc_ffn","twoPts_ffn","fumbles_ffn","pts_ffn")] <-
  apply(projections_ffn[,c("passComp_ffn","passAtt_ffn","passCompPct_ffn","passYds_ffn","passTds_ffn","passInt_ffn","rushAtt_ffn","rushYds_ffn","rushYpc_ffn","rushTds_ffn","rec_ffn","recYds_ffn","recTds_ffn","recYpc_ffn","twoPts_ffn","fumbles_ffn","pts_ffn")], 2, function(x) gsub("\\%", "", x))

#Convert variables from character strings to numeric
projections_ffn[,c("passComp_ffn","passAtt_ffn","passCompPct_ffn","passYds_ffn","passTds_ffn","passInt_ffn","rushAtt_ffn","rushYds_ffn","rushYpc_ffn","rushTds_ffn","rec_ffn","recYds_ffn","recTds_ffn","recYpc_ffn","twoPts_ffn","fumbles_ffn","pts_ffn")] <-
  convert.magic(projections_ffn[,c("passComp_ffn","passAtt_ffn","passCompPct_ffn","passYds_ffn","passTds_ffn","passInt_ffn","rushAtt_ffn","rushYds_ffn","rushYpc_ffn","rushTds_ffn","rec_ffn","recYds_ffn","recTds_ffn","recYpc_ffn","twoPts_ffn","fumbles_ffn","pts_ffn")], "numeric")

#Name for merging
projections_ffn$name <- nameMerge(projections_ffn$name_ffn)

#Remove duplicate cases
projections_ffn[projections_ffn$name %in% projections_ffn[duplicated(projections_ffn$name),"name"],]

#Same name, different player

#Same player, different position

#Calculate overall rank
projections_ffn$overallRank_ffn <- rank(-projections_ffn$pts_ffn, ties.method="min")

#Order variables in data set
projections_ffn <- projections_ffn[,c("name","name_ffn","pos","team_ffn","overallRank_ffn",
                                      "passAtt_ffn","passComp_ffn","passYds_ffn","passTds_ffn","passInt_ffn",
                                      "rushYds_ffn","rushTds_ffn","rec_ffn","recYds_ffn","recTds_ffn","twoPts_ffn","fumbles_ffn","pts_ffn")]

#Order players by overall rank
projections_ffn <- projections_ffn[order(projections_ffn$overallRank_ffn),]
row.names(projections_ffn) <- 1:dim(projections_ffn)[1]

#Density Plot
ggplot(projections_ffn, aes(x=pts_ffn)) + geom_density(fill="orange", alpha=.3) + xlab("Player's Projected Points") + ggtitle("Density Plot of FantasyFootballNerd Projected Points")
ggsave(paste(getwd(),"/Figures/FantasyFootballNerd projections.jpg", sep=""), width=10, height=10)
dev.off()

#Save file
save(projections_ffn, file = paste(getwd(),"/Data/FantasyFootballNerd-Projections.RData", sep=""))
write.csv(projections_ffn, file=paste(getwd(),"/Data/FantasyFootballNerd-Projections.csv", sep=""), row.names=FALSE)

save(projections_ffn, file = paste(getwd(),"/Data/Historical Projections/FantasyFootballNerd-Projections-2014.RData", sep=""))
write.csv(projections_ffn, file=paste(getwd(),"/Data/Historical Projections/FantasyFootballNerd-Projections-2014.csv", sep=""), row.names=FALSE)
