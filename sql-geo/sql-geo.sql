
Geomesa:
https://www.geomesa.org/

https://blog.couchbase.com/pokemon-go-scaling-profile-services-with-couchbase-nosql/


Queries:

DECLARE @p1 geometry
SET @p1= geometry::Parse('POINT(4 5)')
select @p1
select @p1.STAsText() as Ponto1
select @p1.STX, @p1.STY

DECLARE @p2 geography
SET @p2= geography::Point(-23.5641095,  -46.6524099, 4326)
select @p2
select @p2.STAsText() as Ponto2



DECLARE @p3 geography
SET @p3= geography::Parse('POINT(-46.6524099 -23.5641095)')
select @p3
select @p3.STAsText() as Ponto3
select @p3.Lat, @p3.Long


SELECT
  *
FROM
  sys.spatial_reference_systems


SELECT
  well_known_text
FROM
  sys.spatial_reference_systems
WHERE
  authorized_spatial_reference_id = 4326


DECLARE @SydneyHarbourBridge geography
SET @SydneyHarbourBridge =
  geography::STLineFromText(
	'LINESTRING(
  	151.209 -33.855,
  	151.212 -33.850
	)',
	4326
  )
SELECT @SydneyHarbourBridge as linha
SELECT @SydneyHarbourBridge.STAsText() as wktlinha


DECLARE @Poligono geography
SET @Poligono =
geography::STPolyFromText(
  'POLYGON(
  (
	-77.0532238483429 38.870863029297695,
	-77.05468297004701 38.87304314667469,
	-77.05788016319276 38.872800914712734,
	-77.05849170684814 38.870219840133124,
	-77.05556273460388 38.8690670969385,
	-77.0532238483429 38.870863029297695
	)
  )',
 4326
)
SELECT @Poligono as Poligono
SELECT @Poligono.STAsText() as wktpoligono



--http://arthur-e.github.io/Wicket/sandbox-gmaps3.html

--https://clydedacruz.github.io/openstreetmap-wkt-playground/


DECLARE @Pontos geometry
SET @Pontos =
  geometry::STMPointFromText(
	'MULTIPOINT((0 0),(1 2),(2 3),(2 2))',0)
select @Pontos as pontos
select @Pontos.STAsText() as wktpontos



DECLARE @MultiLineString geometry
SET @MultiLineString =
geometry::STMLineFromText(
  'MULTILINESTRING((10 20, 3 4, 43 42),(44 10, 20 40))',0)
select @MultiLineString as multilinhas
select @MultiLineString.STAsText() as wktmultilinhas


DECLARE @MultiPolygon geometry
SET @MultiPolygon =
geometry::STMPolyFromText(
  'MULTIPOLYGON(((10 20, 30 40, 44 50, 10 20)),((5 0, 20 40, 30 34, 5 0)))', 0)
select @MultiPolygon as multipoligonos


DECLARE @GeometryCollection geometry
SET @GeometryCollection = geometry::STGeomCollFromText(
 'GEOMETRYCOLLECTION(
  POLYGON((5 5, 10 5, 10 10, 5 5)),
  POINT(7.8 8.5),
  LINESTRING(4 7,11 1))',0)
select @GeometryCollection



DECLARE @GeometryCollection geometry
SET @GeometryCollection = geometry::STGeomCollFromText(
 'GEOMETRYCOLLECTION
  (
  POLYGON((5 5, 10 5, 10 10, 5 5)),
  POINT(7.8 8.5),
  LINESTRING(4 7,11 1),
  MULTIPOINT((0 0),(1 2),(2 3),(2 2)),
  MULTILINESTRING((10 20, 3 4, 43 42),(44 10, 20 40)),
  MULTIPOLYGON(((10 20, 30 40, 44 50, 10 20)),((5 0, 20 40, 30 34, 5 0)))
  )',0)
select @GeometryCollection


1 - Faça uma busca que retorne a latitude e longitude do campo Location de uma cada das linhas da tabela recentemente criada PropertiesForSale do banco geoserverdb

Select ID, Address, 
Location.Lat as Latitude,
Location.Long as Longitude
from PropertiesForSale


select *, DistrictGeo.STArea() from Districts

select *, DistrictGeo.STIsClosed() from Districts
select *, StreetGeo.STIsClosed() from Streets

select *, StreetGeo.STArea() as Area from Streets

select *, DistrictGeo.STLength() from Districts
select *, StreetGeo.STLength() from Streets


3.1) Faça uma consulta utilizando as tabelas Streets e Districts que retorne as ruas e os respectivos distritos ao qual   cada rua percorre.

Select 
s.StreetId,
s.StreetName,
s.StreetGeo,
d.DistrictId,
d.DistrictName,
d.DistrictGeo
from Districts d, Streets s
Where d.DistrictGeo.STIntersects(s.StreetGeo) = 1


Select 
s.StreetId,
s.StreetName,
s.StreetGeo,
d.DistrictId,
d.DistrictName,
d.DistrictGeo
from  Streets s
inner join Districts d
	on d.DistrictGeo.STIntersects(s.StreetGeo) = 1


3.2) Faça uma consulta utilizando as tabelas Ruas e Cidades que retorne as ruas e as respectivas Cidades ao qual cada rua percorre.



4) Execute o Script World Borders.sql para criar a tabela World_Borders (Já criada no banco de dados na Nuvem). Uma vez carregada faça uma consulta para retornar os dados do Brasil (ISO2 = ‘BR’) e seus vizinhos utilizando a função  STIntersects. Usem a coluna GEOG para as funções de geolocalização.

select * from World_Borders br, World_Borders fronteira
where br.ISO2 = 'BR' and br.GEOG.STIntersects(fronteira.GEOG) = 1





Fazer Download:
https://www.dropbox.com/s/dzp7qse78eplgry/Lim_Municipal.zip?dl=0


5) Com base na consulta do Exercício anterior, faça uma nova consulta que retorne todos os países da América (REGION = 19) que não fazem fronteira com o Brasil.

select
b.NAME,
b.GEOG
from World_Borders a, World_Borders b
where a.ISO2 = 'BR'
and b.REGION = '19'
and a.GEOG.STIntersects(b.GEOG) = 0

6) Utilizando as tabelas Checkin e Cidades faça a contagem da quantidade de Checkin por cidade, utilize as funções STIntersects ou STContains e a função de Count() do próprio SQL Server.

select cid.IDCidade, cid.Nome, Count(ch.IDCheckin) as Total
from Checkin ch, Cidades cid
where cid.CidadeGeo.STContains(ch.PontoGeo) = 1
Group by cid.IDCidade, cid.Nome


select c.*,contagem.Total from Cidades c
inner join (

	select cid.IDCidade, cid.Nome, Count(ch.IDCheckin) as Total
	from Checkin ch, Cidades cid
	where cid.CidadeGeo.STContains(ch.PontoGeo) = 1
	Group by cid.IDCidade, cid.Nome
)as contagem
	on c.IDCidade = contagem.IDCidade


7)  Crie uma variável geográfica do tipo ponto com a   latitude e longitude da FIAP Paulista(-23.5641095,-46.6524099), com esse ponto   calculate a distância de todos os pontos   presentes na tabela Checkin.

DECLARE @pontoFiap geography
SET @pontoFiap= geography::Point(-23.5641095,  -46.6524099, 4326)

select IDCheckin , @pontoFiap.STDistance(PontoGeo) as Distancia
from Checkin
order by Distancia


8)  Com base na consulta anterior, faça uma nova   consulta para buscar todos os registros em um   raio de 5km da Fiap Paulista. 

DECLARE @pontoFiap geography
SET @pontoFiap= geography::Point(-23.5641095,  -46.6524099, 4326)

select IDCheckin, Protocolo ,@pontoFiap.STDistance(PontoGeo) as Distancia
from Checkin
where @pontoFiap.STDistance(PontoGeo) <= 5000