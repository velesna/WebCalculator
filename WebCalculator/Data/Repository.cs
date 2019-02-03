using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Configuration;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace WebCalculator.Data
{
    public class DBContext
    {
        List<string> expressions;
        string connectionstring;

        public DBContext()
        {
            connectionstring = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
        }
        //public async Task<List<string>> GetExpressions(string Adress)
        public List<string> GetExpressions(string Adress)
        {
            using (SqlConnection connection = new SqlConnection(connectionstring))
            {
                using (SqlCommand command = new SqlCommand("sp_GetExpressions", connection))
                {
                    command.Parameters.AddWithValue("@Adress", Adress);
                    command.CommandType = CommandType.StoredProcedure;
                    try
                    {
                        //await connection.OpenAsync();
                        connection.Open();
                        //SqlDataReader reader = await command.ExecuteReaderAsync();
                        SqlDataReader reader = command.ExecuteReader();

                        expressions = new List<string>();
                        while (reader.Read())
                            expressions.Add(reader.GetString(0));
                        reader.Close();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.Message);
                    }
                    finally
                    {
                        connection.Close();
                        Console.WriteLine("Подключение закрыто...");
                    }
                }
            }
            return expressions;
        }
        public void AddExpression(string Adress, string Expression)
        {
            using (SqlConnection connection = new SqlConnection(connectionstring))
            {
                using (SqlCommand command = new SqlCommand("sp_AddExpression", connection))
                {
                    command.Parameters.AddWithValue("@Adress", Adress);
                    command.Parameters.AddWithValue("@Expression", Expression);
                    command.CommandType = CommandType.StoredProcedure;
                    try
                    {
                        connection.Open();
                        command.ExecuteNonQuery();
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(ex.Message);
                    }
                    finally
                    {
                        connection.Close();
                        Console.WriteLine("Подключение закрыто...");
                    }
                }
            }
        }
    }
}