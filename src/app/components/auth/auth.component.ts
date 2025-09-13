import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-auth',
  imports: [CommonModule, FormsModule],
  template: `
    <div class="auth-container">
      <div class="auth-card">
        <h2>{{ isSignUp() ? 'Sign Up' : 'Sign In' }}</h2>
        
        <form (ngSubmit)="handleSubmit()" class="auth-form">
          <div class="form-group">
            <label for="email">Email</label>
            <input
              type="email"
              id="email"
              [(ngModel)]="email"
              name="email"
              required
              placeholder="Enter your email"
            />
          </div>
          
          <div class="form-group">
            <label for="password">Password</label>
            <input
              type="password"
              id="password"
              [(ngModel)]="password"
              name="password"
              required
              placeholder="Enter your password"
              minlength="6"
            />
          </div>
          
          @if (error()) {
            <div class="error-message">{{ error() }}</div>
          }
          
          <button type="submit" [disabled]="loading()" class="submit-btn">
            {{ loading() ? 'Loading...' : (isSignUp() ? 'Sign Up' : 'Sign In') }}
          </button>
        </form>
        
        <p class="toggle-text">
          {{ isSignUp() ? 'Already have an account?' : "Don't have an account?" }}
          <button type="button" (click)="toggleMode()" class="toggle-btn">
            {{ isSignUp() ? 'Sign In' : 'Sign Up' }}
          </button>
        </p>
      </div>
    </div>
  `,
  styles: [`
    .auth-container {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 1rem;
    }

    .auth-card {
      background: white;
      padding: 2rem;
      border-radius: 12px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
      width: 100%;
      max-width: 400px;
    }

    h2 {
      text-align: center;
      margin-bottom: 1.5rem;
      color: #333;
      font-size: 1.5rem;
      font-weight: 600;
    }

    .auth-form {
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .form-group {
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
    }

    label {
      font-weight: 500;
      color: #555;
      font-size: 0.9rem;
    }

    input {
      padding: 0.75rem;
      border: 2px solid #e1e5e9;
      border-radius: 8px;
      font-size: 1rem;
      transition: border-color 0.2s ease;
    }

    input:focus {
      outline: none;
      border-color: #667eea;
    }

    .error-message {
      background: #fee;
      color: #c53030;
      padding: 0.75rem;
      border-radius: 6px;
      font-size: 0.9rem;
      border: 1px solid #fed7d7;
    }

    .submit-btn {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      padding: 0.875rem;
      border-radius: 8px;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: transform 0.2s ease;
    }

    .submit-btn:hover:not(:disabled) {
      transform: translateY(-1px);
    }

    .submit-btn:disabled {
      opacity: 0.7;
      cursor: not-allowed;
    }

    .toggle-text {
      text-align: center;
      margin-top: 1.5rem;
      color: #666;
      font-size: 0.9rem;
    }

    .toggle-btn {
      background: none;
      border: none;
      color: #667eea;
      font-weight: 600;
      cursor: pointer;
      text-decoration: underline;
      margin-left: 0.25rem;
    }

    .toggle-btn:hover {
      color: #764ba2;
    }
  `]
})
export class AuthComponent {
  protected readonly isSignUp = signal(false);
  protected readonly loading = signal(false);
  protected readonly error = signal<string | null>(null);
  
  protected email = '';
  protected password = '';

  constructor(private authService: AuthService) {}

  protected toggleMode() {
    this.isSignUp.update(value => !value);
    this.error.set(null);
  }

  protected async handleSubmit() {
    if (!this.email || !this.password) {
      this.error.set('Please fill in all fields');
      return;
    }

    this.loading.set(true);
    this.error.set(null);

    try {
      const { error } = this.isSignUp()
        ? await this.authService.signUp(this.email, this.password)
        : await this.authService.signIn(this.email, this.password);

      if (error) {
        this.error.set(error.message);
      } else if (this.isSignUp()) {
        this.error.set('Check your email for the confirmation link!');
      }
    } catch (err) {
      this.error.set('An unexpected error occurred');
    } finally {
      this.loading.set(false);
    }
  }
}