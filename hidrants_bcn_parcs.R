library(sf)
library(osmdata)


a <- read_sf("~/zipfolder/Punts_aigua.shp")
# arreglar links fotos
a$linkfoto1 <- ifelse(is.na(a$linkfoto1), NA_character_, paste0("https://incendis.diba.cat/ppi/uploads/fotos/", a$linkfoto1))
a$linkfoto2 <- ifelse(is.na(a$linkfoto2), NA_character_, paste0("https://incendis.diba.cat/ppi/uploads/fotos/", a$linkfoto2))

# canviar noms de columnes que s'utilitzen as is
colnames(a)[colnames(a)=="codi_diba"] <- "ref"
colnames(a)[colnames(a)=="linkfoto1"] <- "image"
colnames(a)[colnames(a)=="linkfoto2"] <- "image:0"
colnames(a)[colnames(a)=="nom_paratg"] <- "description:ca"

# posar columnes amb tipus 
a$tipus_text <- ifelse(a$tipus == 2, "hidrant", "acumulacio")
a$acumulacio_tipus <- factor(a$tip_acum,
                             labels = c(NA_character_, "bassa", "dipòsit cobert", "dipòsit obert", "piscina", "punt natural", "altres"))
a$hidrant_tipus <- factor(a$tip_hidran,
                          labels = c(NA_character_, "arqueta", "columna humida", "columna seca", "armari", "boca de reg"))


a$estat <- factor(a$estat_pa,
                  labels = c(NA_character_,"en servei", "construcció prevista", "arranjament previst"))

# crear columnes amb etiquetes osm

a$emergency <- dplyr::case_when(a$tipus_text == "hidrant" ~ "fire_hydrant",
                                a$acumulacio_tipus %in% c("bassa", "punt natural") ~ "fire_water_pond",
                                a$acumulacio_tipus %in% c("dipòsit cobert",
                                                  "dipòsit obert",
                                                  "piscina",
                                                  "altres") ~ "water_tank")

a$man_made <- ifelse(a$acumulacio_tipus %in% c("bassa",
                                               "dipòsit cobert",
                                               "dipòsit obert"),
                     "storage_tank", NA_character_)
a$natural <- ifelse(a$acumulacio_tipus == "punt natural", "water", NA_character_)
a$content <- ifelse(a$man_made == "storage_tank", "water", NA_character_)
a$water <- ifelse(a$acumulacio_tipus == "bassa", "pond", NA_character_)
a$leisure <- ifelse(a$acumulacio_tipus == "piscina", "swimming_pool", NA_character_)
a$`fire_hydrant:type` <- dplyr::case_when(is.na(a$emergency) ~ NA_character_,
                                                     a$hidrant_tipus == "arqueta" ~ "underground",
                                                     a$hidrant_tipus %in% c("columna humida", "columna seca") ~ "pillar",
                                                     a$hidrant_tipus == "armari" ~ "wall",
                                                     a$hidrant_tipus == "boca de reg" ~ "pipe")

a$`pillar:type` <- dplyr::case_when(a$hidrant_tipus == "columna seca" ~ "dry_barrel",
                                               a$hidrant_tipus == "columna humida" ~ "wet_barrel",
                                               TRUE ~ NA_character_)

a <- st_transform(a[, c("ref", "emergency", "man_made", "natural", "content",
                        "water", "leisure", "fire_hydrant:type", "pillar:type")], 4326) # definitiu i guardar

st_write(a, "~/punts_aigua_def.json", driver = "GeoJSON")


#### jsons parcs ####

# descarregar capa parcs de Catalunya
parcs <- opq("Catalunya") |> 
  add_osm_feature("boundary", "protected_area") |> 
  osmdata_sf()

parcs$osm_multipolygons
parcs$osm_polygons


parcs_capa <- rbind(parcs$osm_multipolygons[,c("name", "geometry")], parcs$osm_polygons[,c("name", "geometry")])
# validar i fer intersecció
parcs_capa <- st_make_valid(parcs_capa)
a <- st_make_valid(a)
a_parcs <- st_intersection(a, parcs_capa)
colnames(a_parcs)[colnames(a_parcs)=="name"] <- "park"
# separar i guardar
a_parcs_split <- split(a_parcs, a_parcs$park)


allNames <- names(a_parcs_split)
for(thisName in allNames){
  saveName = paste0("~/punts_aigua_parcs/",thisName, '.json')
  st_write(a_parcs_split[[thisName]], saveName, driver = "GeoJSON")
}
