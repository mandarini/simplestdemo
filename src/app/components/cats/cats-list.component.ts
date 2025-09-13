import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CatsService } from '../../services/cats.service';
import { AuthService } from '../../services/auth.service';
import type { Cat } from '../../../lib/supabase';

@Component({
  selector: 'app-cats-list',
  imports: [CommonModule, FormsModule],
  template: `
    <div class="cats-container">
      <header class="header">
        <div class="header-content">
          <h1>My Cats 🐱</h1>
          <div class="header-actions">
            <button (click)="showAddForm.set(!showAddForm())" class="add-btn">
              {{ showAddForm() ? 'Cancel' : 'Add Cat' }}
            </button>
            <button (click)="signOut()" class="sign-out-btn">Sign Out</button>
          </div>
        </div>
      </header>

      @if (showAddForm()) {
        <div class="add-form-container">
          <form (ngSubmit)="addCat()" class="add-form">
            <h3>Add New Cat</h3>
            <div class="form-row">
              <input
                type="text"
                [(ngModel)]="newCat.name"
                name="name"
                placeholder="Cat name"
                required
              />
              <input
                type="number"
                [(ngModel)]="newCat.age"
                name="age"
                placeholder="Age"
                min="0"
                max="30"
                required
              />
              <input
                type="text"
                [(ngModel)]="newCat.breed"
                name="breed"
                placeholder="Breed"
                required
              />
            </div>
            <button type="submit" [disabled]="catsService.loading()">
              {{ catsService.loading() ? 'Adding...' : 'Add Cat' }}
            </button>
          </form>
        </div>
      }

      <div class="cats-grid">
        @if (catsService.loading()) {
          <div class="loading">Loading your cats...</div>
        } @else if (catsService.cats().length === 0) {
          <div class="empty-state">
            <h3>No cats yet!</h3>
            <p>Add your first cat to get started.</p>
          </div>
        } @else {
          @for (cat of catsService.cats(); track cat.id) {
            <div class="cat-card">
              <div class="cat-header">
                <h3>{{ cat.name }}</h3>
                <div class="cat-actions">
                  <button (click)="startEdit(cat)" class="edit-btn">✏️</button>
                  <button (click)="deleteCat(cat.id)" class="delete-btn">🗑️</button>
                </div>
              </div>
              
              @if (editingCat()?.id === cat.id) {
                <form (ngSubmit)="saveEdit()" class="edit-form">
                  <input
                    type="text"
                    [(ngModel)]="editForm.name"
                    name="editName"
                    placeholder="Name"
                    required
                  />
                  <input
                    type="number"
                    [(ngModel)]="editForm.age"
                    name="editAge"
                    placeholder="Age"
                    min="0"
                    max="30"
                    required
                  />
                  <input
                    type="text"
                    [(ngModel)]="editForm.breed"
                    name="editBreed"
                    placeholder="Breed"
                    required
                  />
                  <div class="edit-actions">
                    <button type="submit">Save</button>
                    <button type="button" (click)="cancelEdit()">Cancel</button>
                  </div>
                </form>
              } @else {
                <div class="cat-info">
                  <p><strong>Age:</strong> {{ cat.age }} years old</p>
                  <p><strong>Breed:</strong> {{ cat.breed }}</p>
                  <p class="cat-date">Added {{ formatDate(cat.created_at) }}</p>
                </div>
              }
            </div>
          }
        }
      </div>
    </div>
  `,
  styles: [`
    .cats-container {
      min-height: 100vh;
      background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    }

    .header {
      background: white;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
      padding: 1rem 0;
    }

    .header-content {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 1rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    h1 {
      margin: 0;
      color: #333;
      font-size: 1.8rem;
    }

    .header-actions {
      display: flex;
      gap: 1rem;
    }

    .add-btn, .sign-out-btn {
      padding: 0.5rem 1rem;
      border: none;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .add-btn {
      background: #4CAF50;
      color: white;
    }

    .add-btn:hover {
      background: #45a049;
    }

    .sign-out-btn {
      background: #f44336;
      color: white;
    }

    .sign-out-btn:hover {
      background: #da190b;
    }

    .add-form-container {
      max-width: 1200px;
      margin: 2rem auto;
      padding: 0 1rem;
    }

    .add-form {
      background: white;
      padding: 1.5rem;
      border-radius: 12px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .add-form h3 {
      margin: 0 0 1rem 0;
      color: #333;
    }

    .form-row {
      display: grid;
      grid-template-columns: 2fr 1fr 2fr;
      gap: 1rem;
      margin-bottom: 1rem;
    }

    .add-form input {
      padding: 0.75rem;
      border: 2px solid #e1e5e9;
      border-radius: 6px;
      font-size: 1rem;
    }

    .add-form input:focus {
      outline: none;
      border-color: #4CAF50;
    }

    .add-form button {
      background: #4CAF50;
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
    }

    .cats-grid {
      max-width: 1200px;
      margin: 2rem auto;
      padding: 0 1rem;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1.5rem;
    }

    .loading, .empty-state {
      grid-column: 1 / -1;
      text-align: center;
      padding: 3rem;
      background: white;
      border-radius: 12px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .cat-card {
      background: white;
      border-radius: 12px;
      padding: 1.5rem;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      transition: transform 0.2s ease;
    }

    .cat-card:hover {
      transform: translateY(-2px);
    }

    .cat-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1rem;
    }

    .cat-header h3 {
      margin: 0;
      color: #333;
      font-size: 1.2rem;
    }

    .cat-actions {
      display: flex;
      gap: 0.5rem;
    }

    .edit-btn, .delete-btn {
      background: none;
      border: none;
      font-size: 1.2rem;
      cursor: pointer;
      padding: 0.25rem;
      border-radius: 4px;
      transition: background 0.2s ease;
    }

    .edit-btn:hover {
      background: #e3f2fd;
    }

    .delete-btn:hover {
      background: #ffebee;
    }

    .cat-info p {
      margin: 0.5rem 0;
      color: #666;
    }

    .cat-date {
      font-size: 0.9rem;
      color: #999;
      margin-top: 1rem;
    }

    .edit-form {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    .edit-form input {
      padding: 0.5rem;
      border: 1px solid #ddd;
      border-radius: 4px;
    }

    .edit-actions {
      display: flex;
      gap: 0.5rem;
    }

    .edit-actions button {
      padding: 0.5rem 1rem;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 0.9rem;
    }

    .edit-actions button[type="submit"] {
      background: #4CAF50;
      color: white;
    }

    .edit-actions button[type="button"] {
      background: #f5f5f5;
      color: #333;
    }

    @media (max-width: 768px) {
      .form-row {
        grid-template-columns: 1fr;
      }
      
      .header-content {
        flex-direction: column;
        gap: 1rem;
      }
    }
  `]
})
export class CatsListComponent implements OnInit {
  protected readonly showAddForm = signal(false);
  protected readonly editingCat = signal<Cat | null>(null);
  
  protected newCat = {
    name: '',
    age: 0,
    breed: ''
  };

  protected editForm = {
    name: '',
    age: 0,
    breed: ''
  };

  constructor(
    protected catsService: CatsService,
    private authService: AuthService
  ) {}

  ngOnInit() {
    this.catsService.loadCats();
  }

  protected async addCat() {
    if (!this.newCat.name || !this.newCat.breed || this.newCat.age < 0) {
      return;
    }

    const { error } = await this.catsService.addCat(this.newCat);
    
    if (!error) {
      this.newCat = { name: '', age: 0, breed: '' };
      this.showAddForm.set(false);
    }
  }

  protected startEdit(cat: Cat) {
    this.editingCat.set(cat);
    this.editForm = {
      name: cat.name,
      age: cat.age,
      breed: cat.breed
    };
  }

  protected async saveEdit() {
    const cat = this.editingCat();
    if (!cat) return;

    await this.catsService.updateCat(cat.id, this.editForm);
    this.editingCat.set(null);
  }

  protected cancelEdit() {
    this.editingCat.set(null);
  }

  protected async deleteCat(id: string) {
    if (confirm('Are you sure you want to delete this cat?')) {
      await this.catsService.deleteCat(id);
    }
  }

  protected async signOut() {
    await this.authService.signOut();
  }

  protected formatDate(dateString: string): string {
    return new Date(dateString).toLocaleDateString();
  }
}