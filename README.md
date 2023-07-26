# punts_aigua
Aquest repositori conté la localització de tots els hidrants i punts d'acumulació d'aigua contra incendis de la demarcació de Barcelona així com una capa dels que es troben en cada parc natural o zona protegida d'aquest territori.

S'han tractat les dades per a poder pujar-les de manera ràpida a OpenStreetMap: cada punt té totes les etiquetes mínimes per a poder-lo mapejar i que tingui la informació imprescindible. Els arxius json es poden utiltizar per a fer challenges a MapRoulette o eines similars o bé per a utilitzar-los amb ID o JOSM directament.

ATENCIÓ: s'han detectat alguns errors en la informació oferta per la DIBA. Per tant, en cas que el punt tingui una imatge associada **cal comprovar que la informació és correcta**.

## Estructura

**hidrants_bcn_parcs.R** Codi per a netejar les dades obtingudes del [portal GIS de la Diputació de Barcelona](https://gisportal.diba.cat/incendis/). [Informació de les dades aquí. Llicència CC0](https://dadesobertes.diba.cat/datasets/xarxa-de-punts-daigua-de-prevencio-dincendis-forestals).

**punts_aigua_def.json** Capa vectorial amb tots els punts d'aigua preparats per a pujar a OpenStreetMap.

**punts_aigua_parcs** Carpeta amb una capa vectorial pels punts d'aigua de cada parc o zona protegida de la Província de Barcelona.

Per a qualsevol dubte, correcció o apunt, si us plau obriu un issue que el contestarem tant ràpid com puguem.
