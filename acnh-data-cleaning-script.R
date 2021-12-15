# clear the global environment
rm(list=ls())

# set working directory
setwd("~/Documents/Berkeley/info-202")

# load all of the csv files into data frames
insects <- read.csv("~/Documents/Berkeley/info-202/acnh-data-urls/insects.csv",
                     header = T, stringsAsFactors = F)
fish1 <- read.csv("~/Documents/Berkeley/info-202/acnh-data-urls/fish.csv",
                  header = T, stringsAsFactors = F)
fish2 <- read.csv("~/Documents/Berkeley/info-202/acnh-data-2/fish.csv",
                  header = T, stringsAsFactors = F)
creatures <- read.csv("~/Documents/Berkeley/info-202/acnh-data-urls/sea-creatures.csv",
                      header = T, stringsAsFactors = F)

# standardize col names - convert to lowercase, remove periods, use dash for spaces
names(insects) <- tolower(gsub("\\.", "-", names(insects)))
names(fish1) <- tolower(gsub("\\.", "-", names(fish1)))
names(fish2) <- tolower(gsub("\\.", "-", names(fish2)))
names(creatures) <- tolower(gsub("\\.", "-", names(creatures)))

# fix column name for ids
names(insects)[1] <- "id"
names(fish1)[1] <- "id"
names(fish2)[1] <- "id"
names(creatures)[1] <- "id"

# only keep the relevant columns for each data frame
insects <- insects[1:45]
fish1 <- fish1[1:48]
fish2 <- fish2[c("id", "name", "rain-snow-catch-up")]
creatures <- creatures[1:46]

# combine the two fish data sets
fish <- merge(x = fish1, y = fish2, by = c("id","name"), all.x = TRUE)


# ====== STANDARDIZE COLUMNS ACROSS THREE DATA SETS ====== #

# add column indicating creature type
fish$"creature-type" <- "Fish"
insects$"creature-type" <- "Insect"
creatures$"creature-type" <- "Sea Creature"

# convert ids to globally unique ids by prefixing first letter of original data set
fish$id <- sprintf("F%s", fish$id)
insects$id <- sprintf("I%s", insects$id)
creatures$id <- sprintf("C%s", creatures$id)
# insects$id = paste0("I", toString(insects$id))
# creatures$id = paste0("C", toString(creatures$id))

# add NA values to columns that don't apply to other data sets
creatures$"catch-difficulty" <- NA
insects$"catch-difficulty" <- NA
insects$"lighting-type" <- NA
insects$"movement-speed" <- NA
fish$"movement-speed" <- NA
insects$"shadow" <- NA
creatures$"vision" <- NA
insects$"vision" <- NA

# populate where-how column for sea creatures with "Sea" across the board
creatures$"where-how" <- "Sea"

# populate weather column for creatures with "Any weather" across the board
creatures$"weather" <- "Any weather"

# populate weather column for fish with "Any weather" first
fish$"weather" <- "Any weather"

# use rain-snow-catch-up column to populate special weather cases for fish
fish$"weather"[fish$"rain-snow-catch-up" == "Yes"] <- "Any weather (boosted in rain and snow)"

# delete rain-snow-catch-up column after using it to populate weather column
fish <- fish[,-49]

# ========== ASSEMBLE THE FINAL DATA SET ========== #

# order columns alphabetically to bind all three data sets together
fish <- fish[,order(names(fish))]
insects <- insects[,order(names(insects))]
creatures <- creatures[,order(names(creatures))]

# bind rows from fish, insects, creatures data sets
final <- rbind(fish,insects,creatures)

# write final csv to local directory
write.csv(final, "acnh-creatures-data.csv", row.names = FALSE)