//import Foundation
//import Supabase
//
//final class SupabaseManager {
//    static let shared = SupabaseManager()
//
//    let client: SupabaseClient
//
//    private init() {
//        self.client = SupabaseClient(
//            supabaseURL: URL(string: "https://vcmkrmfvvbnxyqsdfkrn.supabase.co")!,
//            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjbWtybWZ2dmJueHlxc2Rma3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMzE4NTYsImV4cCI6MjA5MTkwNzg1Nn0.gYT2mffPGxWvjyg7aXvyASHFeJrngD7ulqs7_3CL6MU"
//        )
//    }
//}


//import Foundation
//import Supabase
//
//final class SupabaseManager {
//    static let shared = SupabaseManager()
//
//    let client: SupabaseClient
//
//    private init() {
//        self.client = SupabaseClient(
//            supabaseURL: URL(string: "https://vcmkrmfvvbnxyqsdfkrn.supabase.co")!,
//            supabaseKey: "sb_publishable_7Wr8IdN6LPkufTIYmhtjmg_IxvZ7crd",
//            options: SupabaseClientOptions(
//                auth: AuthClientOptions(
//                    flowType: .pkce,
//                    autoRefreshToken: true,
//                    persistSession: true,
//                    detectSessionInURL: false,
//                    emitLocalSessionAsInitialSession: true
//                )
//            )
//        )
//    }
//}


import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://vcmkrmfvvbnxyqsdfkrn.supabase.co")!,
            supabaseKey: "sb_publishable_7Wr8IdN6LPkufTIYmhtjmg_IxvZ7crd",
            options: .init(
                auth: .init()
            )
        )
    }
}
