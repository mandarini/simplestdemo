import { Injectable, signal } from '@angular/core';
import { supabase, type Cat } from '../../lib/supabase';

@Injectable({
  providedIn: 'root'
})
export class CatsService {
  private readonly _cats = signal<Cat[]>([]);
  private readonly _loading = signal(false);

  readonly cats = this._cats.asReadonly();
  readonly loading = this._loading.asReadonly();

  async loadCats() {
    this._loading.set(true);
    try {
      const { data, error } = await supabase
        .from('cats')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      this._cats.set(data || []);
    } catch (error) {
      console.error('Error loading cats:', error);
      this._cats.set([]);
    } finally {
      this._loading.set(false);
    }
  }

  async addCat(cat: Omit<Cat, 'id' | 'created_at' | 'owner_id'>) {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('User not authenticated');

      const { data, error } = await supabase
        .from('cats')
        .insert([{ ...cat, owner_id: user.id }])
        .select()
        .single();

      if (error) throw error;
      
      // Refresh the cats list
      await this.loadCats();
      return { data, error: null };
    } catch (error) {
      console.error('Error adding cat:', error);
      return { data: null, error };
    }
  }

  async updateCat(id: string, updates: Partial<Omit<Cat, 'id' | 'created_at' | 'owner_id'>>) {
    try {
      const { data, error } = await supabase
        .from('cats')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      
      // Refresh the cats list
      await this.loadCats();
      return { data, error: null };
    } catch (error) {
      console.error('Error updating cat:', error);
      return { data: null, error };
    }
  }

  async deleteCat(id: string) {
    try {
      const { error } = await supabase
        .from('cats')
        .delete()
        .eq('id', id);

      if (error) throw error;
      
      // Refresh the cats list
      await this.loadCats();
      return { error: null };
    } catch (error) {
      console.error('Error deleting cat:', error);
      return { error };
    }
  }
}