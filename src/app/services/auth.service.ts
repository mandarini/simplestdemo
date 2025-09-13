import { Injectable, signal } from '@angular/core';
import { supabase } from '../../lib/supabase';
import type { User } from '@supabase/supabase-js';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly _user = signal<User | null>(null);
  private readonly _loading = signal(true);

  readonly user = this._user.asReadonly();
  readonly loading = this._loading.asReadonly();

  constructor() {
    this.initializeAuth();
  }

  private async initializeAuth() {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      this._user.set(session?.user ?? null);
      
      supabase.auth.onAuthStateChange((event, session) => {
        this._user.set(session?.user ?? null);
      });
    } catch (error) {
      console.error('Error initializing auth:', error);
    } finally {
      this._loading.set(false);
    }
  }

  async signUp(email: string, password: string) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    return { data, error };
  }

  async signIn(email: string, password: string) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { data, error };
  }

  async signOut() {
    const { error } = await supabase.auth.signOut();
    return { error };
  }
}