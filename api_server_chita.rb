require 'net/http'
require 'json'
require 'date'

require 'rest-client'

def obtener_cotizacion(rut_emisor, rut_receptor, monto_factura, folio, fecha_vencimiento)
  api_key = "pZX5rN8qAdgzCe0cAwpnQQtt"
  query_params = {
    client_dni: rut_emisor,
    debtor_dni: rut_receptor,
    document_amount: monto_factura,
    folio: folio,
    expiration_date: fecha_vencimiento
  }

  endpoint = "https://chita.cl/api/v1/pricing/simple_quote"
  headers = { 'X-Api-Key' => api_key, 'params' => query_params }

  response = RestClient.get(endpoint, headers)

  if response.code == 200
    puts "Respuesta de la API: #{response.body}"
  else
    puts "Error al hacer la solicitud: #{response.code} - #{response.body}"
  end

  data = JSON.parse(response.body)

  document_rate = data["document_rate"]
  commission = data["commission"]
  advance_percent = data["advance_percent"]

  #calcular la diferencia entre días
  def calculate_days_until_deadline(fecha_vencimiento)
    deadline_date = Date.parse(fecha_vencimiento)
    current_date = Date.today
    days_remaining = (deadline_date - current_date).to_i + 1
    return days_remaining
  end

  # Cálculo del costo de financiamiento
  finantial_cost = (monto_factura * (advance_percent / 100.0) * ((document_rate / 100.0) / 30 * calculate_days_until_deadline(fecha_vencimiento))).round(2)

  # Cálculo del monto a recibir
  amount_to_receive = ((monto_factura * (advance_percent / 100.0)) - (finantial_cost + commission)).round(2)

  # Cálculo de los excedentes
  surplus = (monto_factura - (monto_factura * (advance_percent / 100.0))).round(2)

  # Imprimir resultados
  puts "Costo de financiamiento: $#{finantial_cost}"
  puts "Monto a recibir: $#{amount_to_receive}"
  puts "Excedentes: $#{surplus}"

  return {
    costo_financiamiento: finantial_cost,
    monto_a_recibir: amount_to_receive,
    excedentes: surplus
  }
end

# Datos de prueba chita (ejemplo)
rut_emisor = '76329692-K'
rut_receptor = '77360390-1'
monto_factura = 1000000
folio = 75
fecha_vencimiento = '2024-03-12'

obtener_cotizacion(rut_emisor, rut_receptor, monto_factura, folio, fecha_vencimiento)