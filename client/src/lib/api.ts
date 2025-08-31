import { Event, Volunteer, Rsvp } from '@/types';

const API_BASE_URL = "http://localhost:8090";

class ApiError extends Error {
  constructor(message: string, public status?: number) {
    super(message);
    this.name = 'ApiError';
  }
}

async function apiRequest<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;
  
  try {
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    });

    if (!response.ok) {
      throw new ApiError(`HTTP ${response.status}: ${response.statusText}`, response.status);
    }

    return await response.json();
  } catch (error) {
    if (error instanceof ApiError) throw error;
    throw new ApiError('Network error occurred');
  }
}

export const api = {
  health: () => apiRequest('/health'),
  
  events: {
    list: () => apiRequest('/events'),
    create: (event: Omit<Event, 'id' | 'createdAt'>) => 
      apiRequest('/events', {
        method: 'POST',
        body: JSON.stringify(event),
      }),
  },
  
  volunteers: {
    list: () => apiRequest('/volunteers'),
    create: (volunteer: Omit<Volunteer, 'id' | 'createdAt'>) =>
      apiRequest('/volunteers', {
        method: 'POST',
        body: JSON.stringify(volunteer),
      }),
  },
  
  rsvps: {
    create: (rsvp: Omit<Rsvp, 'id' | 'createdAt'>) =>
      apiRequest('/rsvps', {
        method: 'POST',
        body: JSON.stringify(rsvp),
      }),
  },
  
  match: (volunteerId: string) => apiRequest(`/match?volunteerId=${volunteerId}`),
};

export { ApiError };